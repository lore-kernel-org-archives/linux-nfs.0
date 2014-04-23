Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25612 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbaDWXbF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 19:31:05 -0400
From: Devesh Sharma <Devesh.Sharma@Emulex.Com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: RE: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
Date: Wed, 23 Apr 2014 23:30:59 +0000
Message-ID: <1bab6615-60c4-4865-a6a0-c53bb1c32341@CMEXHTCAS1.ad.emulex.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com>
 <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com>
 <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com>
 <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com>
 <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com>
 <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com>
 <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com>
 <6837A427-B677-4CC7-A022-4FB9E52A3FC6@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDED915@CMEXMB1.ad.emulex.com>
 <C689AB91-46F6-4E96-A673-0DE76FE54CC4@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEE11F@CMEXMB1.ad.emulex.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FDEE11F@CMEXMB1.ad.emulex.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck

Following is the complete call trace of a typical NFS-RDMA transaction while mounting a share.
It is unavoidable to stop calling post-send in case it is not created. Therefore, applying checks to the connection state is a must
While registering/deregistering frmrs on-the-fly. The unconnected state of QP implies don't call  post_send/post_recv from any context.

call_start nfs4 proc GETATTR (sync)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_reserve (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 reserved req ffff8804678b8800 xid 53abc98d
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_event_process: event rep ffff88046230f980 status 0 opcode 7 length 48
Apr 23 20:00:34 neo03-el64 kernel: RPC:       wake_up_next(ffff880465ae6190 "xprt_sending")
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_reserveresult (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_refresh (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 looking up UNIX cred
Apr 23 20:00:34 neo03-el64 kernel: RPC:       looking up UNIX cred
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 refreshing UNIX cred ffff880467b2cec0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_refreshresult (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_allocate (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:       xprt_rdma_allocate: size 1052 too large for buffer[1024]: prog 100003 vers 4 proc 1
Apr 23 20:00:34 neo03-el64 kernel: RPC:       xprt_rdma_allocate: size 1052, request 0xffff8804650e2000

------------->>>>>> A new buffer is allocated from the Pre-Created Buffer pool, and since buffer is smaller to hold requested data size <<<<<<<-----------------
------------->>>>>> allocate new, do book keeping and create phys_mr for the newly allocated buffer.

Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_bind (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_connect xprt ffff880465ae6000 is connected
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_transmit (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 xprt_prepare_transmit
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 xprt_cwnd_limited cong = 0 cwnd = 4096
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 rpc_xdr_encode (status 0)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 marshaling UNIX cred ffff880467b2cec0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 using AUTH_UNIX cred ffff880467b2cec0 to wrap rpc data
Apr 23 20:00:34 neo03-el64 kernel: encode_compound: tag=
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 xprt_transmit(120)
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_inline_pullup: pad 0 destp 0xffff8804650e37d8 len 120 hdrlen 120
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_register_frmr_external: Using frmr ffff88046230ef30 to map 1 segments

---------------->>>>>>>>> This is where post_send is called for FRMR creations. If xprt is not connected, even then post_send call continues with FRMR cration.
--------------->>>>>>>>>> if QP is connected call post send else fail the reg-call and submit the buffers back to the pools and start over with call_bind() at RPC layer.

Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_create_chunks: reply chunk elem 592@0x4650e392c:0x805f505 (last)
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_marshal_req: reply chunk: hdrlen 48 rpclen 120 padlen 0 headerp 0xffff8804650e3100 base 0xffff8804650e3760 lkey 0x0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 xmit complete
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 sleep_on(queue "xprt_pending" time 4296808435)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 added to queue ffff880465ae6258 "xprt_pending"
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 setting alarm for 60000 ms
Apr 23 20:00:34 neo03-el64 kernel: RPC:       wake_up_next(ffff880465ae6190 "xprt_sending")
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 sync task going to sleep
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_event_process: event rep ffff88046230ef30 status 0 opcode 8 length 48
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_event_process: event rep ffff88046502a000 status 0 opcode 80 length 48

---------------->>>>>>>>>> If the completion is Flush, Update the QP connection state immediately, don't wait for tasklet to schedule.
 
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_reply_handler: reply 0xffff88046502a000 completes request 0xffff8804650e2000
Apr 23 20:00:34 neo03-el64 kernel:                   RPC request 0xffff8804678b8800 xid 0x8dc9ab53
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_count_chunks: chunk 212@0x4650e392c:0x805f505
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_reply_handler: xprt_complete_rqst(0xffff880465ae6000, 0xffff8804678b8800, 212)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 xid 53abc98d complete (212 bytes received)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 __rpc_wake_up_task (now 4296808436)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 disabling timer
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 removed from queue ffff880465ae6258 "xprt_pending"
Apr 23 20:00:34 neo03-el64 kernel: RPC:       __rpc_wake_up_task done
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 sync task resuming
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_status (status 212)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_decode (status 212)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 validating UNIX cred ffff880467b2cec0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 using AUTH_UNIX cred ffff880467b2cec0 to unwrap rpc data
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_type: type=040000
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_change: change attribute=952326959717679104
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_size: file size=4096
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_fsid: fsid=(0x0/0x0)
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_fileid: fileid=2
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_fs_locations: fs_locations done, error = 0
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_mode: file mode=0555
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_nlink: nlink=32
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_owner: uid=0
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_group: gid=0
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_rdev: rdev=(0x0:0x0)
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_space_used: space used=8192
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_time_access: atime=1398288115
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_time_metadata: ctime=1398290189
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_time_modify: mtime=1398290189
Apr 23 20:00:34 neo03-el64 kernel: decode_attr_mounted_on_fileid: fileid=0
Apr 23 20:00:34 neo03-el64 kernel: decode_getfattr_attrs: xdr returned 0
Apr 23 20:00:34 neo03-el64 kernel: decode_getfattr_generic: xdr returned 0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 call_decode result 0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 return 0, status 0
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 release task
Apr 23 20:00:34 neo03-el64 kernel: RPC:       wake_up_next(ffff880465ae6190 "xprt_sending")
Apr 23 20:00:34 neo03-el64 kernel: RPC:       xprt_rdma_free: called on 0xffff88046502a000

--------->>>>>xprt_rdma_free calls ib_post_send irrespective of QP connection state. Apply check here as-well.

------------->>>>>>>>> xprt_rdma_free internally tries to invalidate FRMRs, If QP is not connected, free-up buffer without invalidation modify the state of frmr.state = INVALID.

Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 release request ffff8804678b8800
Apr 23 20:00:34 neo03-el64 kernel: RPC:       wake_up_next(ffff880465ae6320 "xprt_backlog")
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpc_release_client(ffff8804651c1e00)
Apr 23 20:00:34 neo03-el64 kernel: RPC:   178 freeing task
Apr 23 20:00:34 neo03-el64 kernel: NFS: nfs_fhget(0:21/2 ct=1)
Apr 23 20:00:34 neo03-el64 kernel: <-- nfs4_get_root()
Apr 23 20:00:34 neo03-el64 kernel: RPC:       looking up Generic cred
Apr 23 20:00:34 neo03-el64 kernel: RPC:       rpcrdma_event_process: event rep ffff88046230ef30 status 0 opcode 7 length 48

----------->>>>> New Task Initialised<<<<<<<<<---------------
Apr 23 20:00:34 neo03-el64 kernel: RPC:       new task initialized, procpid 3491

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Devesh Sharma
> Sent: Tuesday, April 15, 2014 11:56 PM
> To: Chuck Lever
> Cc: Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond Myklebust
> Subject: RE: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> 
> 
> 
> > -----Original Message-----
> > From: Chuck Lever [mailto:chuck.lever@oracle.com]
> > Sent: Tuesday, April 15, 2014 6:10 AM
> > To: Devesh Sharma
> > Cc: Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond
> > Myklebust
> > Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> >
> >
> > On Apr 14, 2014, at 6:46 PM, Devesh Sharma
> <devesh.sharma@emulex.com>
> > wrote:
> >
> > > Hi Chuck
> > >
> > >> -----Original Message-----
> > >> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> > >> Sent: Tuesday, April 15, 2014 2:24 AM
> > >> To: Devesh Sharma
> > >> Cc: Linux NFS Mailing List; linux-rdma@vger.kernel.org; Trond
> > >> Myklebust
> > >> Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> > >>
> > >> Hi Devesh-
> > >>
> > >>
> > >> On Apr 13, 2014, at 12:01 AM, Chuck Lever <chuck.lever@oracle.com>
> > wrote:
> > >>
> > >>>
> > >>> On Apr 11, 2014, at 7:51 PM, Devesh Sharma
> > >> <Devesh.Sharma@Emulex.Com> wrote:
> > >>>
> > >>>> Hi  Chuck,
> > >>>> Yes that is the case, Following is the trace I got.
> > >>>>
> > >>>> <4>RPC:   355 setting alarm for 60000 ms
> > >>>> <4>RPC:   355 sync task going to sleep
> > >>>> <4>RPC:       xprt_rdma_connect_worker: reconnect
> > >>>> <4>RPC:       rpcrdma_ep_disconnect: rdma_disconnect -1
> > >>>> <4>RPC:       rpcrdma_ep_connect: rpcrdma_ep_disconnect status -1
> > >>>> <3>ocrdma_mbx_create_qp(0) rq_err
> > >>>> <3>ocrdma_mbx_create_qp(0) sq_err
> > >>>> <3>ocrdma_create_qp(0) error=-1
> > >>>> <4>RPC:       rpcrdma_ep_connect: rdma_create_qp failed -1
> > >>>> <4>RPC:   355 __rpc_wake_up_task (now 4296956756)
> > >>>> <4>RPC:   355 disabling timer
> > >>>> <4>RPC:   355 removed from queue ffff880454578258 "xprt_pending"
> > >>>> <4>RPC:       __rpc_wake_up_task done
> > >>>> <4>RPC:       xprt_rdma_connect_worker: exit
> > >>>> <4>RPC:   355 sync task resuming
> > >>>> <4>RPC:   355 xprt_connect_status: error 1 connecting to server
> > >> 192.168.1.1
> > >>>
> > >>> xprtrdma's connect worker is returning "1" instead of a negative errno.
> > >>> That's the bug that triggers this chain of events.
> > >>
> > >> rdma_create_qp() has returned -EPERM. There's very little xprtrdma
> > >> can do if the provider won't even create a QP. That seems like a
> > >> rare and fatal problem.
> > >>
> > >> For the moment, I'm inclined to think that a panic is correct
> > >> behavior, since there are outstanding registered memory regions
> > >> that cannot be cleaned up without a QP (see below).
> > > Well, I think the system should still remain alive.
> >
> > Sure, in the long run. I'm not suggesting we leave it this way.
> Okay, Agreed.
> >
> > > This will definatly cause a memory leak. But QP create failure does
> > > not
> > mean system should also crash.
> >
> > It's more than leaked memory.  A permanent QP creation failure can
> > leave pages in the page cache registered and pinned, as I understand it.
> Yes! true.
> >
> > > I think for the time being it is worth to put Null pointer checks to
> > > prevent
> > system from crash.
> >
> > Common practice in the Linux kernel is to avoid unnecessary NULL checks.
> > Work-around fixes are typically rejected, and not with a happy face either.
> >
> > Once the connection tear-down code is fixed, it should be clear where
> > NULL checks need to go.
> Okay.
> >
> > >>
> > >>> RPC tasks waiting for the reconnect are awoken.
> > >>> xprt_connect_status() doesn't recognize a tk_status of "1", so it
> > >>> turns it into -EIO, and kills each waiting RPC task.
> > >>
> > >>>> <4>RPC:       wake_up_next(ffff880454578190 "xprt_sending")
> > >>>> <4>RPC:   355 call_connect_status (status -5)
> > >>>> <4>RPC:   355 return 0, status -5
> > >>>> <4>RPC:   355 release task
> > >>>> <4>RPC:       wake_up_next(ffff880454578190 "xprt_sending")
> > >>>> <4>RPC:       xprt_rdma_free: called on 0x(null)
> > >>>
> > >>> And as part of exiting, the RPC task has to free its buffer.
> > >>>
> > >>> Not exactly sure why req->rl_nchunks is not zero for an NFSv4
> GETATTR.
> > >>> This is why rpcrdma_deregister_external() is invoked here.
> > >>>
> > >>> Eventually this gets around to attempting to post a LOCAL_INV WR
> > >>> with
> > >>> ->qp set to NULL, and the panic below occurs.
> > >>
> > >> This is a somewhat different problem.
> > >>
> > >> Not only do we need to have a good ->qp here, but it has to be
> > >> connected and in the ready-to-send state before LOCAL_INV work
> > >> requests can be posted.
> > >>
> > >> The implication of this is that if a server disconnects (server
> > >> crash or network partition), the client is stuck waiting for the
> > >> server to come back before it can deregister memory and retire
> > >> outstanding RPC
> > requests.
> > > This is a real problem to solve. In the existing state of xprtrdma
> > > code. Even a Server reboot will cause Client to crash.
> >
> > I don't see how that can happen if the HCA/provider manages to create
> > a fresh QP successfully and then rdma_connect() succeeds.
> Okay yes, since QP creation will still succeed.
> >
> > A soft timeout or a ^C while the server is rebooting might be a problem.
> >
> > >>
> > >> This is bad for ^C or soft timeouts or umount ... when the server
> > >> is unavailable.
> > >>
> > >> So I feel we need better clean-up when the client cannot reconnect.
> > > Unreg old frmrs with the help of new QP? Until the new QP is created
> > > with
> > same PD and FRMR is bound to PD and not to QP.
> > >> Probably deregistering RPC chunk MR's before finally tearing down
> > >> the old QP is what is necessary.
> > >
> > > We need a scheme that handles Memory registrations separately from
> > connection establishment and do book-keeping of which region is
> > Registered and which one is not.
> > > Once the new connection is back. Either start using old mem-regions
> > > as it is,
> > or invalidate old and re-register on the new QP.
> > > What is the existing scheme xprtrdma is following? Is it the same?
> >
> > This is what is going on now.  Clearly, when managing its own memory
> > resources, the client should never depend on the server ever coming back.
> >
> > The proposal is to deregister _before_ the old QP is torn down, using
> > ib_dereg_mr() in the connect worker process. All RPC requests on that
> > connection should be sleeping waiting for the reconnect to complete.
> >
> > If chunks are created and marshaled during xprt_transmit(), the
> > waiting RPC requests should simply re-register when they are ready to be
> sent again.
> >
> Ok, I will try to change this and test, I may take a week's time to understand
> and rollout V3.
> 
> > > I think it is possible to create FRMR on qp->qp_num = x while
> > > invalidate on qp->qp_num = y until qpx.pd == qpy.pd
> >
> > --
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> >
> >
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
