Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36482 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbLDABd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2015 19:01:33 -0500
Received: by ykdr82 with SMTP id r82so105830398ykd.3
        for <linux-nfs@vger.kernel.org>; Thu, 03 Dec 2015 16:01:33 -0800 (PST)
Date: Thu, 3 Dec 2015 19:01:27 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com
Subject: Re: Call graph of nfsd_open
Message-ID: <20151203190127.4b20121b@synchrony.poochiereds.net>
In-Reply-To: <C4AC976E-608D-4B2D-9835-C444EF0E1325@oracle.com>
References: <C4AC976E-608D-4B2D-9835-C444EF0E1325@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Dec 2015 13:31:13 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi-
> 
> I’m looking into NFS WRITE latency on the Linux NFS server.
> With a high speed network fabric and ultra-fast storage (think
> persistent memory) we can get the per-WRITE latency under 50us
> (as observed on the wire at the server).
> 
> One source of the remaining latency appears to be nfsd_open.
> Here is an example of a call graph captured during a simple
> iozone 4KB direct write workload (v4.4-rc3):
> 
>  2)               |            nfsd_open [nfsd]() {
>  2)               |              fh_verify [nfsd]() {
>  2)               |                rqst_exp_find [nfsd]() {
>  2)               |                  exp_find [nfsd]() {
>  2)               |                    exp_find_key [nfsd]() {
>  2)   0.043 us    |                      svc_expkey_hash [nfsd]();
>  2)               |                      sunrpc_cache_lookup [sunrpc]() {
>  2)   0.027 us    |                        _raw_read_lock();
>  2)               |                        getboottime64() {
>  2)   0.022 us    |                          ns_to_timespec();
>  2)   0.210 us    |                        }
>  2)   0.021 us    |                        get_seconds();
>  2)   0.854 us    |                      }
>  2)               |                      cache_check [sunrpc]() {
>  2)               |                        getboottime64() {
>  2)   0.021 us    |                          ns_to_timespec();
>  2)   0.206 us    |                        }
>  2)   0.022 us    |                        get_seconds();
>  2)   0.596 us    |                      }
>  2)   2.050 us    |                    }
>  2)               |                    exp_get_by_name [nfsd]() {
>  2)               |                      svc_export_lookup [nfsd]() {
>  2)               |                        sunrpc_cache_lookup [sunrpc]() {
>  2)   0.022 us    |                          _raw_read_lock();
>  2)   0.024 us    |                          svc_export_match [nfsd]();
>  2)               |                          getboottime64() {
>  2)   0.023 us    |                            ns_to_timespec();
>  2)   0.210 us    |                          }
>  2)   0.022 us    |                          get_seconds();
>  2)   0.997 us    |                        }
>  2)   1.181 us    |                      }
>  2)               |                      cache_check [sunrpc]() {
>  2)               |                        getboottime64() {
>  2)   0.022 us    |                          ns_to_timespec();
>  2)   0.210 us    |                        }
>  2)   0.022 us    |                        get_seconds();
>  2)   0.592 us    |                      }
>  2)   2.147 us    |                    }
>  2)   4.560 us    |                  }
>  2)   4.768 us    |                }
>  2)               |                prepare_creds() {
>  2)               |                  kmem_cache_alloc() {
>  2)   0.021 us    |                    _cond_resched();
>  2)   0.233 us    |                  }
>  2)               |                  security_prepare_creds() {
>  2)               |                    selinux_cred_prepare() {
>  2)               |                      kmemdup() {
>  2)               |                        __kmalloc_track_caller() {
>  2)   0.022 us    |                          kmalloc_slab();
>  2)   0.023 us    |                          _cond_resched();
>  2)   0.448 us    |                        }
>  2)   0.640 us    |                      }
>  2)   0.838 us    |                    }
>  2)   1.129 us    |                  }
>  2)   1.808 us    |                }
>  2)   0.022 us    |                override_creds();
>  2)               |                exportfs_decode_fh() {
>  2)               |                  shmem_fh_to_dentry() {
>  2)               |                    ilookup5() {
>  2)               |                      ilookup5_nowait() {
>  2)   0.026 us    |                        _raw_spin_lock();
>  2)               |                        find_inode() {
>  2)   0.031 us    |                          shmem_match();
>  2)   0.029 us    |                          _raw_spin_lock();
>  2)   0.429 us    |                        }
>  2)   0.826 us    |                      }
>  2)   0.022 us    |                      _cond_resched();
>  2)   0.021 us    |                      _cond_resched();
>  2)   1.417 us    |                    }
>  2)               |                    d_find_alias() {
>  2)   0.022 us    |                      _raw_spin_lock();
>  2)   0.027 us    |                      _raw_spin_lock();
>  2)   0.423 us    |                    }
>  2)   0.035 us    |                    iput();
>  2)   2.410 us    |                  }
>  2)               |                  find_acceptable_alias() {
>  2)   0.026 us    |                    nfsd_acceptable [nfsd]();
>  2)   0.220 us    |                  }
>  2)   3.032 us    |                }
>  2)               |                nfsd_setuser_and_check_port [nfsd]() {
>  2)   0.023 us    |                  nfsexp_flags [nfsd]();
>  2)               |                  nfsd_setuser [nfsd]() {
>  2)               |                    revert_creds() {
>  2)               |                      __put_cred() {
>  2)               |                        call_rcu_sched() {
>  2)               |                          __call_rcu() {
>  2)   0.049 us    |                            __call_rcu_nocb_enqueue();
>  2)   0.265 us    |                          }
>  2)   0.446 us    |                        }
>  2)   0.661 us    |                      }
>  2)   0.854 us    |                    }
>  2)               |                    prepare_creds() {
>  2)               |                      kmem_cache_alloc() {
>  2)   0.022 us    |                        _cond_resched();
>  2)   0.219 us    |                      }
>  2)               |                      security_prepare_creds() {
>  2)               |                        selinux_cred_prepare() {
>  2)               |                          kmemdup() {
>  2)               |                            __kmalloc_track_caller() {
>  2)   0.024 us    |                              kmalloc_slab();
>  2)   0.022 us    |                              _cond_resched();
>  2)   0.412 us    |                            }
>  2)   0.615 us    |                          }
>  2)   0.801 us    |                        }
>  2)   0.993 us    |                      }
>  2)   1.651 us    |                    }
>  2)   0.033 us    |                    set_groups();
>  2)   0.023 us    |                    override_creds();
>  2)   3.323 us    |                  }
>  2)   0.029 us    |                  nfserrno [nfsd]();
>  2)   3.919 us    |                }
>  2)   0.025 us    |                check_nfsd_access [nfsd]();
>  2)   0.022 us    |                nfsd_permission [nfsd]();
>  2) + 14.904 us   |              }
> 
> So, 15us for fh_verify by itself.
> 
>  2)               |              dentry_open() {
>  2)               |                get_empty_filp() {
>  2)               |                  kmem_cache_alloc() {
>  2)   0.021 us    |                    _cond_resched();
>  2)   0.325 us    |                  }
>  2)               |                  security_file_alloc() {
>  2)               |                    selinux_file_alloc_security() {
>  2)               |                      kmem_cache_alloc() {
>  2)   0.022 us    |                        _cond_resched();
>  2)   0.251 us    |                      }
>  2)   0.441 us    |                    }
>  2)   0.633 us    |                  }
>  2)   0.022 us    |                  __mutex_init();
>  2)   1.572 us    |                }
>  2)               |                vfs_open() {
>  2)               |                  do_dentry_open() {
>  2)               |                    path_get() {
>  2)   0.025 us    |                      mntget();
>  2)   0.313 us    |                    }
>  2)   0.029 us    |                    try_module_get();
>  2)               |                    security_file_open() {
>  2)               |                      selinux_file_open() {
>  2)   0.024 us    |                        avc_policy_seqno();
>  2)               |                        inode_has_perm.isra.21() {
>  2)   0.148 us    |                          avc_has_perm();
>  2)   0.332 us    |                        }
>  2)   0.728 us    |                      }
>  2)   0.023 us    |                      __fsnotify_parent();
>  2)   0.034 us    |                      fsnotify();
>  2)   1.359 us    |                    }
>  2)   0.045 us    |                    file_ra_state_init();
>  2)   2.548 us    |                  }
>  2)   2.733 us    |                }
>  2)   4.667 us    |              }
>  2)               |              ima_file_check() {
>  2)   0.028 us    |                process_measurement();
>  2)   0.211 us    |              }
>  2)   0.023 us    |              nfserrno [nfsd]();
>  2) + 20.549 us   |            }
> 
> And that’s 20us total for this nfsd_open. Seems like a lot of
> work for each NFSv3 WRITE operation, and plenty of opportunities
> for lock contention if my server happened to be otherwise busy.
> 
> Note these figures are a little inflated because ftrace itself
> adds some latency.
> 
> Anyway, making fh_verify faster could have a significant
> impact on per-op latency with fast storage. The recently-proposed
> NFSD open cache by itself could eliminate the need to perform
> fh_verify so often, for example.
> 

No, we still have to do a fh_verify. We still have to do a
nfsd_permission check, etc (in particular). What we _can_ avoid is
calling down into the vfs layer to do the actual open. Maybe it's
possible to optimize away some of the fh_verify processing though?
Personally, I think the fh_* routines do too much...

In any case, the latest set that I have is here:

    https://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfsd-4.5

...but note that Trond and Tao have merged some fixes to our internal
repo for this that I have not yet had time to review yet. I'll probably
pick those up next week sometime once I've gotten caught up.

-- 
Jeff Layton <jlayton@poochiereds.net>
