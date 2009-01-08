From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Thu, 8 Jan 2009 16:26:05 -0500
Message-ID: <20090108212605.GG19312@fieldses.org>
References: <1227737539.31008.2.camel@localhost.localdomain> <1228090631.7112.11.camel@heimdal.trondhjem.org> <1228169383.20370.3.camel@localhost.localdomain> <1228565812.10856.30.camel@localhost.localdomain> <1229279045.3721.1.camel@localhost.localdomain> <20081216175503.GG16388@fieldses.org> <1229452775.3721.25.camel@localhost.localdomain> <20090107222115.GI965@fieldses.org> <20090108182003.GB17623@fieldses.org> <1231449753.21688.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:43536 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762940AbZAHV0T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 16:26:19 -0500
In-Reply-To: <1231449753.21688.12.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2009 at 09:22:33PM +0000, Ian Campbell wrote:
> On Thu, 2009-01-08 at 13:20 -0500, J. Bruce Fields wrote:
> > On Wed, Jan 07, 2009 at 05:21:15PM -0500, J. Bruce Fields wrote:
> > > On Tue, Dec 16, 2008 at 06:39:35PM +0000, Ian Campbell wrote:
> > > > That's right, it was actually 2.6.26.7 FWIW.
> > > > 
> > > > > I'll try to take a look at these before I leave for the holidays,
> > > > > assuming the versions Trond posted on Nov. 30 are the latest.
> > > > 
> > > > Thanks.
> > > 
> > > Sorry for getting behind.
> > > 
> > > If you got a chance to retest with the for-2.6.29 branch at
> > > 
> > > 	git://linux-nfs.org/~bfields/linux.git for-2.6.29
> > > 
> > > that'd be great; that's what I intend to send to Linus.
> > 
> > (Merged now, so testing mainline as of today should work too.)
> 
> The server isn't really a machine I want to test random kernels on, is
> there some subset of those changesets which it would be useful for me to
> pull back onto the 2.6.26 kernel I'm using to test? (I can most like
> manage the backporting myself).
> 
> These two look like the relevant ones to me but I'm not sure:
> 22945e4a1c7454c97f5d8aee1ef526c83fef3223 svc: Clean up deferred requests on transport destruction
> 69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a SUNRPC: Ensure the server closes sockets in a timely fashion
> 
> I think 69b6 was in the set of three I tested previously and the other
> two turned into 2294?

Yep, exactly.--b.

> 
> Ian.
> 
> Full list 238c6d54830c624f34ac9cf123ac04aebfca5013..nfs-bfields/for-2.6.29:
> db43910cb42285a99f45f7e0a0a32e32d0b61dcf nfsd: get rid of NFSD_VERSION
> 87df4de8073f922a1f643b9fa6ba0412d5529ecf nfsd: last_byte_offset
> 4e65ebf08951326709817e654c149d0a94982e01 nfsd: delete wrong file comment from nfsd/nfs4xdr.c
> df96fcf02a5fd2ae4e9b09e079dd6ef12d10ecd7 nfsd: git rid of nfs4_cb_null_ops declaration
> 0407717d8587f60003f4904bff27650cd836c00c nfsd: dprint each op status in nfsd4_proc_compound
> b7aeda40d3010666d2c024c80557b6aa92a1a1ad nfsd: add etoosmall to nfserrno
> 30fa8c0157e4591ee2227aaa0b17cd3b0da5e6cb NFSD: FIDs need to take precedence over UUIDs
> 24c3767e41a6a59d32bb45abe899eb194e6bf1b8 SUNRPC: The sunrpc server code should not be used by out-of-tree modules
> 22945e4a1c7454c97f5d8aee1ef526c83fef3223 svc: Clean up deferred requests on transport destruction
> 9a8d248e2d2e9c880ac4561f27fea5dc200655bd nfsd: fix double-locks of directory mutex
> 2779e3ae39645515cb6c1126634f47c28c9e7190 svc: Move kfree of deferral record to common code
> f05ef8db1abe68e3f6fc272efee51bc54ce528c5 CRED: Fix NFSD regression
> 0dba7c2a9ed3d4a1e58f5d94fffa9f44dbe012e6 NLM: Clean up flow of control in make_socks() function
> d3fe5ea7cf815c037c90b1f1464ffc1ab5e8601b NLM: Refactor make_socks() function
> 55ef1274dddd4de387c54d110e354ffbb6cdc706 nfsd: Ensure nfsv4 calls the underlying filesystem on LOCKT
> 69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a SUNRPC: Ensure the server closes sockets in a timely fashion
> 262a09823bb07c6aafb6c1d312cde613d0b90c85 NFSD: Add documenting comments for nfsctl interface
> 9e074856caf13ba83363f73759f5e395f74ccf41 NFSD: Replace open-coded integer with macro
> 54224f04ae95d86b27c0673cd773ebb120d86876 NFSD: Fix a handful of coding style issues in write_filehandle()
> b046ccdc1f8171f6d0129dcc2a28d49187b4bf69 NFSD: clean up failover sysctl function naming
> b064ec038a6180b13e5f89b6a30b42cb5ce8febc lockd: Enable NLM use of AF_INET6
> 57ef692588bc225853ca3267ca5b7cea2b07e058 NLM: Rewrite IPv4 privileged requester's check
> d1208f70738c91f13b4eadb1b7a694082e439da2 NLM: nlm_privileged_requester() doesn't recognize mapped loopback address
> 49b5699b3fc22b363534c509c1b7dba06bc677bf NSM: Move nsm_create()
> b7ba597fb964dfa44284904b3b3d74d44b8e1c42 NSM: Move nsm_use_hostnames to mon.c
> 8529bc51d30b8f001734b29b21a51b579c260f5b NSM: Move nsm_addr() to fs/lockd/mon.c
> e6765b83977f07983c7a10e6bbb19d6c7bbfc3a4 NSM: Remove include/linux/lockd/sm_inter.h
> 94da7663db26530a8377f7219f8be8bd4d4822c2 NSM: Replace IP address as our nlm_reboot lookup key
> 77a3ef33e2de6fc8aabd7cb1700bfef81757c28a NSM: More clean up of nsm_get_handle()
> b39b897c259fc1fd1998505f2b1d4ec1f115bce1 NSM: Refactor nsm_handle creation into a helper function
> 92fd91b998a5216a6d6606704e71d541a180216c NLM: Remove "create" argument from nsm_find()
> 8c7378fd2a5f22016542931b887a2ae98d146eaf NLM: Call nsm_reboot_lookup() instead of nsm_find()
> 3420a8c4359a189f7d854ed7075d151257415447 NSM: Add nsm_lookup() function
> 576df4634e37e46b441fefb91915184edb13bb94 NLM: Decode "priv" argument of NLMPROC_SM_NOTIFY as an opaque
> 7fefc9cb9d5f129c238d93166f705c96ca2e7e51 NLM: Change nlm_host_rebooted() to take a single nlm_reboot argument
> cab2d3c99165abbba2943f1b269003b17fd3b1cb NSM: Encode the new "priv" cookie for NSMPROC_MON requests
> 7e44d3bea21fbb9494930d1cd35ca92a9a4a3279 NSM: Generate NSMPROC_MON's "priv" argument when nsm_handle is created
> 05f3a9af58180d24a9decedd71d4587935782d70 NSM: Remove !nsm check from nsm_release()
> bc1cc6c4e476b60df48227165990c87a22db6bb7 NSM: Remove NULL pointer check from nsm_find()
> 5cf1c4b19db99d21d44c2ab457cfd44eb86b4439 NSM: Add dprintk() calls in nsm_find and nsm_release
> 67c6d107a689243979a2b5f15244b5261634a924 NSM: Move nsm_find() to fs/lockd/mon.c
> 03eb1dcbb799304b58730f4dba65812f49fb305e NSM: move to xdr_stream-based XDR encoders and decoders
> 36e8e668d3e6a61848a8921ddeb663b417299fa5 NSM: Move NSM program and procedure numbers to fs/lockd/mon.c
> 9c1bfd037f7ff8badaecb47418f109148d88bf45 NSM: Move NSM-related XDR data structures to lockd's xdr.h
> 0c7aef4569f8680951b7dee01dddffb9d2f809ff NSM: Check result of SM_UNMON upcall
> 356c3eb466fd1a12afd6448d90fba3922836e5f1 NLM: Move the public declaration of nsm_unmonitor() to lockd.h
> c8c23c423dec49cb439697d3dc714e1500ff1610 NSM: Release nsmhandle in nlm_destroy_host
> 1e49323c4ab044d05bbc68cf13cadcbd4372468c NLM: Move the public declaration of nsm_monitor() to lockd.h
> 5d254b119823658cc318f88589c6c426b3d0a153 NSM: Make sure to return an error if the SM_MON call result is not zero
> 5bc74bef7c9b652f0f2aa9c5a8d5ac86881aba79 NSM: Remove BUG_ON() in nsm_monitor()
> 501c1ed3fb5c2648ba1709282c71617910917f66 NLM: Remove redundant printk() in nlmclnt_lock()
> 9fee49024ed19d849413df4ab6ec1a1a60aaae94 NSM: Use sm_name instead of h_name in nsm_monitor() and nsm_unmonitor()
> 29ed1407ed81086b778ebf12145b048ac3f7e10e NSM: Support IPv6 version of mon_name
> f47534f7f0ac7727e05ec4274b764b181df2cf7f NSM: Use modern style for sm_name field in nsm_handle
> 5acf43155d1bcc412d892c73f64044f9a826cde6 NSM: convert printk(KERN_DEBUG) to a dprintk()
> a4846750f090702e2fb848ac4fe5827bcef34060 NSM: Use C99 structure initializer to initialize nsm_args
> afb03699dc0a920aed3322ad0e6895533941fb1e NLM: Add helper to handle IPv4 addresses
> bc995801a09d1fead0bec1356bfd836911c8eed7 NLM: Support IPv6 scope IDs in nlm_display_address()
> 6999fb4016b2604c2f8a65586bba4a62a4b24ce7 NLM: Remove AF_UNSPEC arm in nlm_display_address()
> 1df40b609ad5a622904eb652109c287fe9c93ec5 NLM: Remove address eye-catcher buffers from nlm_host
> 7538ce1eb656a1477bedd5b1c202226e7abf5e7b NLM: Use modern style for pointer fields in nlm_host
> c72a476b4b7ecadb80185de31236edb303c1a5d0 lockd: set svc_serv->sv_maxconn to a more reasonable value (try #3)
> c9233eb7b0b11ef176d4bf68da2ce85464b6ec39 sunrpc: add sv_maxconn field to svc_serv (try #3)
> 548eaca46b3cf4419b6c2be839a106d8641ffb70 nfsd: document new filehandle fsid types
> 2bd9e7b62e6e1da3f881c40c73d93e9a212ce6de nfsd: Fix leaked memory in nfs4_make_rec_clidname
> 9346eff0dea1e5855fba25c9fe639d92a4db3135 nfsd: Minor cleanup of find_stateid
> b3d47676d474ecd914c72049c87e71e5f0ffe040 nfsd: update fh_verify description
> 
> 
> -- 
> Ian Campbell
> 
> You're definitely on their list.  The question to ask next is what list it is.


