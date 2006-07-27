From: Li Guanglei <guanglei@cn.ibm.com>
Subject: Re: [ltc-perf]  draft of nfs event hook
Date: Thu, 27 Jul 2006 21:57:05 +0800
Message-ID: <44C8C631.40003@cn.ibm.com>
References: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <systemtap-return-3830-gls-systemtap=m.gmane.org@sourceware.org>
To: "systemtap@sourceware.org" <systemtap@sourceware.org>,         nfs@lists.sourceforge.net
In-Reply-To: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

   The NFS trace hooks we are working on will be part of the trace 
hooks of LKET, which is a system trace tool and we mainly use it for 
performance analysis.

   LKET is a dynamic trace facility based on SystemTap. It is actually 
implemented as SystemTap's tapsets library and it has been integrated 
into SystemTap already. For more info of LKET, you can refer to:

http://sourceware.org/systemtap/man5/lket.5.html

   When we started working on NFS trace hooks, we realized it is not 
an easy task. Although we use NFS in daily work but we don't have much 
knowledge about the NFS protocol details and its implementation inside 
the Kernel. So I divided the work into two steps. At the first step I 
need get a list of trace points. And at the second step I need to make 
sure what trace data is available for each trace hook. In a short, the 
trace data available for each hook will be derived from the arguments 
of the kernel functions being probed.

   We read through the Kernel source code and chose some functions to 
be instrumented. We will trace the entry of these functions and if 
necessary, the return of them will also be traced. The following is 
the list of these functions, please take a review:

==================== Client Side ==========================

<1> nfs directory operations

      All functions from nfs_dir_operations:

       const struct file_operations nfs_dir_operations = {
         .llseek         = nfs_llseek_dir,
         .read           = generic_read_dir,
         .readdir        = nfs_readdir,
         .open           = nfs_opendir,
         .release        = nfs_release,
         .fsync          = nfs_fsync_dir,
};

<2> nfs file operations

     All functions from nfs_file_operations:

     const struct file_operations nfs_file_operations = {
         .llseek         = nfs_file_llseek,
         .read           = do_sync_read,
         .write          = do_sync_write,
         .aio_read               = nfs_file_read,
         .aio_write              = nfs_file_write,
         .mmap           = nfs_file_mmap,
         .open           = nfs_file_open,
         .flush          = nfs_file_flush,
         .release        = nfs_file_release,
         .fsync          = nfs_fsync,
         .lock           = nfs_lock,
         .flock          = nfs_flock,
         .sendfile       = nfs_file_sendfile,
         .check_flags    = nfs_check_flags,
};

<3> nfs address space operations:
     All functions from nfs_file_aops:

       struct address_space_operations nfs_file_aops = {
         .readpage = nfs_readpage,
         .readpages = nfs_readpages,
         .set_page_dirty = __set_page_dirty_nobuffers,
         .writepage = nfs_writepage,
         .writepages = nfs_writepages,
         .prepare_write = nfs_prepare_write,
         .commit_write = nfs_commit_write,
         .invalidatepage = nfs_invalidate_page,
         .releasepage = nfs_release_page,
#ifdef CONFIG_NFS_DIRECTIO
         .direct_IO = nfs_direct_IO,
#endif
      };

<4> NFS RPC procedures:

    All functions from nfs_v[2,3,4]_clientops:
     I only list the nfs_v3 rpc procedures:
      struct nfs_rpc_ops      nfs_v3_clientops = {
         .version        = 3,                    /* protocol version */
         .dentry_ops     = &nfs_dentry_operations,
         .dir_inode_ops  = &nfs3_dir_inode_operations,
         .file_inode_ops = &nfs3_file_inode_operations,
         .getroot        = nfs3_proc_get_root,
         .getattr        = nfs3_proc_getattr,
         .setattr        = nfs3_proc_setattr,
         .lookup         = nfs3_proc_lookup,
         .access         = nfs3_proc_access,
         .readlink       = nfs3_proc_readlink,
         .read           = nfs3_proc_read,
         .write          = nfs3_proc_write,
         .commit         = nfs3_proc_commit,
         .create         = nfs3_proc_create,
         .remove         = nfs3_proc_remove,
         .unlink_setup   = nfs3_proc_unlink_setup,
         .unlink_done    = nfs3_proc_unlink_done,
         .rename         = nfs3_proc_rename,
         .link           = nfs3_proc_link,
         .symlink        = nfs3_proc_symlink,
         .mkdir          = nfs3_proc_mkdir,
         .rmdir          = nfs3_proc_rmdir,
         .readdir        = nfs3_proc_readdir,
         .mknod          = nfs3_proc_mknod,
         .statfs         = nfs3_proc_statfs,
         .fsinfo         = nfs3_proc_fsinfo,
         .pathconf       = nfs3_proc_pathconf,
         .decode_dirent  = nfs3_decode_dirent,
         .read_setup     = nfs3_proc_read_setup,
         .read_done      = nfs3_read_done,
         .write_setup    = nfs3_proc_write_setup,
         .write_done     = nfs3_write_done,
         .commit_setup   = nfs3_proc_commit_setup,
         .commit_done    = nfs3_commit_done,
         .file_open      = nfs_open,
         .file_release   = nfs_release,
         .lock           = nfs3_proc_lock,
         .clear_acl_cache = nfs3_forget_cached_acls,
     };

   The LKET already has syscall and iosyscall trace hooks. So with the 
above trace hooks, LKET could trace different layer of NFS operations:
    --> Syscall
       --> struct file_operations
           --> struct address_space_operations
                --> struct nfs_rpc_ops

======================= Server Side =============================

<1> nfsd_dispatch
    This is the NFS dispatching function sit on top of RPC.

<2> NFS RPC procedures:

     For NFSv4, it will be nfsd4_proc_compound

     For NFSv2, NFSv3, it will be the functions from nfsd_procedures[2,3]

     Here is a list for NFSv3, NFSv2 are almost the same:
       nfsd3_proc_null,
       nfsd3_proc_getattr,
       nfsd3_proc_setattr,
       nfsd3_proc_lookup,
       nfsd3_proc_access,
       nfsd3_proc_readlink,
       nfsd3_proc_read,
       nfsd3_proc_write,
       nfsd3_proc_create,
       nfsd3_proc_mkdir,
       nfsd3_proc_symlink,
       nfsd3_proc_mknod,
       nfsd3_proc_remove,
       nfsd3_proc_rmdir,
       nfsd3_proc_rename,
       nfsd3_proc_link,
       nfsd3_proc_readdir,
       nfsd3_proc_readdirplus,readdirplus,
       nfsd3_proc_fsstat,
       nfsd3_proc_fsinfo,
       nfsd3_proc_pathconf,
       nfsd3_proc_commit,

<3> NFSD file VFS operations

      The functions nfsd_xxx from "fs/nfsd/vfs.c"

With the above server side trace hooks, LKET could trace NFS 
operations at different layer:

      nfsd_dispatch -->
         --> NFS RPC Procedures
            --> NFS VFS file operations


   What I didn't list about NFS operations includes authentication, 
NFSv4 callback and RPC(I prefer to use a separate set of trace hooks 
for RPC). I am not sure if these operations are also required to be 
traced. If I missed some important functions or I listed some 
redundant functions, please feel free to let me know. Any comments 
will be highly appreciated.

   Thanks.

The following is from Li Xuepeng posted on nfs@lists.sourceforge.net 
which involved some implementations details and its trace point lists 
is a subset of the above.

- Guanglei

Xue Peng Li ??:
> Hi folks,
> 
> I am working on NFS trace hooks for SystemTap/LKET. These trace
> hooks could be used for performance analyzing which will trace both
> NFS client and server side activities.
> 
> At the first step I need make sure that the trace hooks I defined
> are appropriate and every trace hook probes the right places inside
> the Kernel. So I will be appreciated if you could help me review the
> following trace hooks.
> 
> 
> Thanks
> 
> ======================== NFS Client Side Trace Hooks =================
> 
> The following event hooks are used to trace nfs client activities.
> These event hooks are divided into two groups. Probe Point and
> Description is given for each event hook.
> 
> Group1:
> It contains 15 event hooks, which are used to probe Client-side
> NFS procedures.
> ---------------------------------------------------------------------
> addevent.nfs.proc.read_setup
> Probe Point:
> nfs_proc_read_setup,nfs3_proc_read_setup, nfs4_proc_read_setup
> Description:
> Setup a rpc task to prepare for reading
> ---------------------------------------------------------------------
> addevent.nfs.proc.read_done
> Probe Point:
> nfs_proc_read_done,nfs3_proc_read_done,
> nfs4_proc_read_done
> Description:
> Fires when receive a read reply from server,it is used to
> refresh the inode on client
> ---------------------------------------------------------------------
> addevnet.nfs.proc.read
> Probe Point:
> nfs_proc_read,nfs3_proc_read,nfs4_proc_read
> Description:
> Send a read operation to server,and refresh local inode after
> receive reply from server
> ---------------------------------------------------------------------
> addevent.nfs.proc.write_setup
> Probe Point:
> nfs_proc_write_setup,nfs3_proc_write_setup,nfs4_proc_write_setup
> Description:
> ---------------------------------------------------------------------
> addevent.nfs.proc.write
> Probe Point:
> nfs_proc_write,nfs3_proc_write,nfs4_proc_write
> Description:
> Send a write operation to server
> ---------------------------------------------------------------------
> addevent.nfs.proc.write_done
> Probe Point:
> nfs_write_done,nfs3_write_done,nfs4_write_done
> Description:
> Fires when receive a write reply from server,it is used to
> refresh the inode on client
> ---------------------------------------------------------------------
> addevent.nfs.proc.open
> Probe Point:
> nfs_open
> Description:
> Allocate file read/write context information
> ---------------------------------------------------------------------
> addevent.nfs.proc.release
> Probe Point:
> nfs_release
> Description:
> Release file read/write context information
> ---------------------------------------------------------------------
> addevent.nfs.proc.create
> Probe Point:
> nfs_create
> Description:
> Create a new file or dir on server
> _____________________________________________________________________
> 
> Group2:
> This group includes the event hooks which probe NFS address space
> operation related function.All the functions are common in NFSV2,
> NFSV3,NFSV4.
> ---------------------------------------------------------------------
> addevent.nfs.aops.readpage
> Probe Point:
> nfs_readpage
> Description :
> Read the page ,only fires when a previous async read operation
> failed
> ---------------------------------------------------------------------
> addevent.nfs.aops.readpages
> Probe Point:
> nfs_readpages
> Description:
> Fires when in readahead way,read several pages once
> ---------------------------------------------------------------------
> addevent.nfs.aops.writepage
> Probe Point:
> nfs_writepage
> Description:
> Write an mapped page to the server
> ---------------------------------------------------------------------
> addevent.nfs.aops.writepages
> Probe Point:
> nfs_writepages
> Description:
> Write several dirty pages to the serve once
> ---------------------------------------------------------------------
> addevent.nfs.aops.prepare_write
> Probe Point:
> prepare_write
> Description:
> Prepare a page for writing. Look for a request corresponding
> to the page. If there is one, and it belongs to another aops,
> we flush it out before we try to copy anything into the page.
> Also do the same if we find a request from an existing
> dropped page.
> ---------------------------------------------------------------------
> addevent.nfs.aops.commit_write
> Probe Point:
> nfs_commit_write
> Description :
> Update and possibly write a cached page of an NFS aops
> _____________________________________________________________________
> 
> 
> ====================== NFS Server Side Trace Hooks ==================
> 
> The following event hooks are used to traced nfs server activities.
> The event hooks are divided into three group.
> 
> Group1:
> It contains one event hook,which probes nfsd_dispatch
> ---------------------------------------------------------------------
> addevent.nfsd.dispatch
> Probe Point:
> nfsd_dispatch
> Description:
> Decode the arguments received from client,call the procedure
> handler,encode the result
> ______________________________________________________________________
> Group2:
> It contains three event hooks.The functions probed will be called
> by related procedure handler. All the functions are common in NFSV2,
> NFSV3,NFSV4
> ---------------------------------------------------------------------
> addevent.nfsd.read
> Probe Point:
> nfsd_read
> Description:
> It does the "real" work of read
> ---------------------------------------------------------------------
> addevent.nfsd.write
> Probe Point:
> nfsd_write
> Description:
> It does the "real " work of write
> ---------------------------------------------------------------------
> addevent.nfsd.open
> Probe Point:
> nfsd_open
> Description:
> Open an existing file or directory.
> ---------------------------------------------------------------------
> addevent.nfsd.close
> Probe Point:
> nfsd_close
> Description:
> Close an existing file or directory
> _____________________________________________________________________
> Group3:
> It contains eight event hooks,which probe procedure handlers.
> ---------------------------------------------------------------------
> addevent.nfsd.proc2.read
> Probe Point:
> nfsd_proc_read
> Description:
> Read data from file (NFSV2)
> ---------------------------------------------------------------------
> addevent.nfsd.proc3.read
> Probe Point:
> nfsd3_proc_read
> Description:
> Read data from file (NFSV3)
> ---------------------------------------------------------------------
> addevent.nfsd.proc4.read
> Probe Point:
> nfsd4_read
> Description:
> Check stateid and prepare for reading
> ---------------------------------------------------------------------
> addevent.nfsd.proc2.write
> Probe Point:
> nfsd_proc_write
> Description:
> Write data to file (NFSV2)
> ---------------------------------------------------------------------
> addevent.nfsd.pro3.write
> Probe Point:
> nfsd3_proc_write
> Description:
> Write data to file (NFSV3)
> ---------------------------------------------------------------------
> addevent.nfsd.proc4.write
> Probe Point:
> nfsd4_write
> Description:
> Check stateid and write data to file
> ---------------------------------------------------------------------
> addevent.nfsd.proc4.open
> Probe Point:
> nfsd4_open
> Description:
> Check stateid and open file
> ---------------------------------------------------------------------
> addevent.nfsd.proc4.compound
> Probe Point:
> nfsd4_proc_compound
> Description:
> Call different procedures according to client request
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> ltc-perf mailing list
> ltc-perf@linux.ibm.com
> http://linux.ibm.com/mailman/listinfo/ltc-perf
