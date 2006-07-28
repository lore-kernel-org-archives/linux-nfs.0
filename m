From: Xue Peng Li <xuepengl@cn.ibm.com>
Subject: Re: [ltc-perf] draft of nfs event hook
Date: Fri, 28 Jul 2006 11:35:28 +0800
Message-ID: <OFB44FCA2F.FA1EACB9-ON482571B9.0012AE12-482571B9.00135311@cn.ibm.com>
References: <76bd70e30607260650j726cb7f1mb7ff812ae5d54bd8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0062673653=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6J63-0004H2-1W
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 20:33:07 -0700
Received: from ausmtp06.au.ibm.com ([202.81.18.155])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6J61-0007oS-Bl
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 20:33:07 -0700
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp06.au.ibm.com (8.13.6/8.13.6) with ESMTP id k6S3YW8W8839242
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 13:34:32 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id
	k6S3a8nM184528
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 13:36:15 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k6S3WiWt008143
	for <nfs@lists.sourceforge.net>; Fri, 28 Jul 2006 13:32:44 +1000
In-Reply-To: <76bd70e30607260650j726cb7f1mb7ff812ae5d54bd8@mail.gmail.com>
To: "Chuck Lever" <chucklever@gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0062673653==
Content-type: multipart/alternative;
	Boundary="0__=C7BBFB2ADF8128828f9e8a93df938690918cC7BBFB2ADF812882"
Content-Disposition: inline

--0__=C7BBFB2ADF8128828f9e8a93df938690918cC7BBFB2ADF812882
Content-type: text/plain; charset=US-ASCII



"Chuck Lever" <chucklever@gmail.com> wrote on 2006-07-26 21:50:42:

> Xue Peng ---
>
> I've only glanced at your specification, but it occurs to me that it
> would be helpful for reviewers to understand your intent of adding the
> hooks where you did.  Do you have a design document, even a short one?
>  Or can you discuss your decisions on the list with us?

Guanglei posted an updated mail of NFS trace hooks which included a link to
LKET manual page.

>
> For example, why hook all three of "setup" "read/write" and "done" ?
>

read is for sync operations. While setup/done pair is used for async
operations.


> And, what value do you hope these hooks will add over and above the
> performance metrics that I added in 2.6.17 ?  We see the SystemTap
> hooks as an opportunity to make more specialized (and potentially more
> run-time expensive) observations than the performance metrics.
These hooks can used to trace NFS activities ,which is a new hook group
>
> Are there other file systems that have hooks in them?  Did you add
> hooks in conventional/standard places for all file systems?

Thomas Zanussi from IBM is working on ext3 hooks. The hooks into other fs
may be our plan of next step.

>
> Thanks!
>
> On 7/26/06, Xue Peng Li <xuepengl@cn.ibm.com> wrote:
> >
> >
> >
> > Hi folks,
> >
> >  I am working on NFS trace hooks for SystemTap/LKET. These trace
> >  hooks could be used for performance analyzing which will trace both
> >  NFS client and server side activities.
> >
> >  At the first step I need make sure that the trace hooks I defined
> >  are appropriate and every trace hook probes the right places inside
> >  the Kernel. So I will be appreciated if you could help me review the
> >  following trace hooks.
> >
> >
> >  Thanks
> >
> >  ======================== NFS Client Side Trace Hooks =================
> >
> >  The following event hooks are used to trace nfs client activities.
> >  These event hooks are divided into two groups. Probe Point and
> >  Description is given for each event hook.
> >
> >  Group1:
> >  It contains 15 event hooks, which are used to probe Client-side
> >  NFS procedures.
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.read_setup
> >  Probe Point:
> >  nfs_proc_read_setup,nfs3_proc_read_setup,
> > nfs4_proc_read_setup
> >  Description:
> >  Setup a rpc task to prepare for reading
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.read_done
> >  Probe Point:
> >  nfs_proc_read_done,nfs3_proc_read_done,
> >  nfs4_proc_read_done
> >  Description:
> >  Fires when receive a read reply from server,it is used to
> >  refresh the inode on client
> > ---------------------------------------------------------------------
> >  addevnet.nfs.proc.read
> >  Probe Point:
> >  nfs_proc_read,nfs3_proc_read,nfs4_proc_read
> >  Description:
> >  Send a read operation to server,and refresh local inode after
> >  receive reply from server
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.write_setup
> >  Probe Point:
> > nfs_proc_write_setup,nfs3_proc_write_setup,nfs4_proc_write_setup
> >  Description:
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.write
> >  Probe Point:
> >  nfs_proc_write,nfs3_proc_write,nfs4_proc_write
> >  Description:
> >  Send a write operation to server
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.write_done
> >  Probe Point:
> >  nfs_write_done,nfs3_write_done,nfs4_write_done
> >  Description:
> >  Fires when receive a write reply from server,it is used to
> >  refresh the inode on client
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.open
> >  Probe Point:
> >  nfs_open
> >  Description:
> >  Allocate file read/write context information
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.release
> >  Probe Point:
> >  nfs_release
> >  Description:
> >  Release file read/write context information
> > ---------------------------------------------------------------------
> >  addevent.nfs.proc.create
> >  Probe Point:
> >  nfs_create
> >  Description:
> >  Create a new file or dir on server
> > _____________________________________________________________________
> >
> >  Group2:
> >  This group includes the event hooks which probe NFS address space
> >  operation related function.All the functions are common in NFSV2,
> >  NFSV3,NFSV4.
> > ---------------------------------------------------------------------
> >  addevent.nfs.aops.readpage
> >  Probe Point:
> >  nfs_readpage
> >  Description :
> >  Read the page ,only fires when a previous async read operation
> >  failed
> > ---------------------------------------------------------------------
> >  addevent.nfs.aops.readpages
> >  Probe Point:
> >  nfs_readpages
> >  Description:
> >  Fires when in readahead way,read several pages once
> > ---------------------------------------------------------------------
> >  addevent.nfs.aops.writepage
> >  Probe Point:
> >  nfs_writepage
> >  Description:
> >  Write an mapped page to the server
> > ---------------------------------------------------------------------
> >  addevent.nfs.aops.writepages
> >  Probe Point:
> >  nfs_writepages
> >  Description:
> >  Write several dirty pages to the serve once
> > ---------------------------------------------------------------------
> >  addevent.nfs.aops.prepare_write
> >  Probe Point:
> >  prepare_write
> >  Description:
> >  Prepare a page for writing. Look for a request corresponding
> >  to the page. If there is one, and it belongs to another aops,
> >  we flush it out before we try to copy anything into the page.
> >  Also do the same if we find a request from an existing
> >  dropped page.
> > ---------------------------------------------------------------------
> >  addevent.nfs.aops.commit_write
> >  Probe Point:
> >  nfs_commit_write
> >  Description :
> >  Update and possibly write a cached page of an NFS aops
> > _____________________________________________________________________
> >
> >
> >  ====================== NFS Server Side Trace Hooks ==================
> >
> >  The following event hooks are used to traced nfs server activities.
> >  The event hooks are divided into three group.
> >
> >  Group1:
> >  It contains one event hook,which probes nfsd_dispatch
> > ---------------------------------------------------------------------
> >  addevent.nfsd.dispatch
> >  Probe Point:
> >  nfsd_dispatch
> >  Description:
> >  Decode the arguments received from client,call the procedure
> >  handler,encode the result
> > ______________________________________________________________________
> >  Group2:
> >  It contains three event hooks.The functions probed will be called
> >  by related procedure handler. All the functions are common in NFSV2,
> >  NFSV3,NFSV4
> > ---------------------------------------------------------------------
> >  addevent.nfsd.read
> >  Probe Point:
> >  nfsd_read
> >  Description:
> >  It does the "real" work of read
> > ---------------------------------------------------------------------
> >  addevent.nfsd.write
> >  Probe Point:
> >  nfsd_write
> >  Description:
> >  It does the "real " work of write
> > ---------------------------------------------------------------------
> >  addevent.nfsd.open
> >  Probe Point:
> >  nfsd_open
> >  Description:
> >  Open an existing file or directory.
> > ---------------------------------------------------------------------
> >  addevent.nfsd.close
> >  Probe Point:
> >  nfsd_close
> >  Description:
> >  Close an existing file or directory
> > _____________________________________________________________________
> >  Group3:
> >  It contains eight event hooks,which probe procedure handlers.
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc2.read
> >  Probe Point:
> >  nfsd_proc_read
> >  Description:
> >  Read data from file (NFSV2)
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc3.read
> >  Probe Point:
> >  nfsd3_proc_read
> >  Description:
> >  Read data from file (NFSV3)
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc4.read
> >  Probe Point:
> >  nfsd4_read
> >  Description:
> >  Check stateid and prepare for reading
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc2.write
> >  Probe Point:
> >  nfsd_proc_write
> >  Description:
> >  Write data to file (NFSV2)
> > ---------------------------------------------------------------------
> >  addevent.nfsd.pro3.write
> >  Probe Point:
> >  nfsd3_proc_write
> >  Description:
> >  Write data to file (NFSV3)
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc4.write
> >  Probe Point:
> >  nfsd4_write
> >  Description:
> >  Check stateid and write data to file
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc4.open
> >  Probe Point:
> >  nfsd4_open
> >  Description:
> >  Check stateid and open file
> > ---------------------------------------------------------------------
> >  addevent.nfsd.proc4.compound
> >  Probe Point:
> >  nfsd4_proc_compound
> >  Description:
> >  Call different procedures according to client request
> >
> >
-------------------------------------------------------------------------
> > Take Surveys. Earn Cash. Influence the Future of IT
> > Join SourceForge.net's Techsay panel and you'll get the chance to share
your
> > opinions on IT & business topics through brief surveys -- and earn cash
> >
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> >
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
> >
>
>
> --
> "We who cut mere stones must always be envisioning cathedrals"
>    -- Quarry worker's creed
--0__=C7BBFB2ADF8128828f9e8a93df938690918cC7BBFB2ADF812882
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&quot;Chuck Lever&quot; &lt;chucklever@gmail.com&gt; wrote on 2006-07-26 21:50:42:<br>
<br>
&gt; Xue Peng ---<br>
&gt; <br>
&gt; I've only glanced at your specification, but it occurs to me that it<br>
&gt; would be helpful for reviewers to understand your intent of adding the<br>
&gt; hooks where you did. &nbsp;Do you have a design document, even a short one?<br>
&gt; &nbsp;Or can you discuss your decisions on the list with us?</tt><br>
<br>
<tt>Guanglei posted an updated mail of NFS trace hooks which included a link to LKET manual page.</tt><br>
<tt><br>
&gt; <br>
&gt; For example, why hook all three of &quot;setup&quot; &quot;read/write&quot; and &quot;done&quot; ?<br>
&gt; </tt><br>
<br>
<tt>read is for sync operations. While setup/done pair is used for async operations.</tt><br>
<br>
<tt><br>
&gt; And, what value do you hope these hooks will add over and above the<br>
&gt; performance metrics that I added in 2.6.17 ? &nbsp;We see the SystemTap<br>
&gt; hooks as an opportunity to make more specialized (and potentially more<br>
&gt; run-time expensive) observations than the performance metrics.</tt><br>
<tt>These hooks can used to trace NFS activities ,which is a new hook group<br>
&gt; <br>
&gt; Are there other file systems that have hooks in them? &nbsp;Did you add<br>
&gt; hooks in conventional/standard places for all file systems?</tt><br>
<br>
<tt>Thomas Zanussi from IBM is working on ext3 hooks. The hooks into other fs may be our plan of next step.</tt><br>
<tt><br>
&gt; <br>
&gt; Thanks!<br>
&gt; <br>
&gt; On 7/26/06, Xue Peng Li &lt;xuepengl@cn.ibm.com&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Hi folks,<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;I am working on NFS trace hooks for SystemTap/LKET. These trace<br>
&gt; &gt; &nbsp;hooks could be used for performance analyzing which will trace both<br>
&gt; &gt; &nbsp;NFS client and server side activities.<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;At the first step I need make sure that the trace hooks I defined<br>
&gt; &gt; &nbsp;are appropriate and every trace hook probes the right places inside<br>
&gt; &gt; &nbsp;the Kernel. So I will be appreciated if you could help me review the<br>
&gt; &gt; &nbsp;following trace hooks.<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;Thanks<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;======================== NFS Client Side Trace Hooks =================<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;The following event hooks are used to trace nfs client activities.<br>
&gt; &gt; &nbsp;These event hooks are divided into two groups. Probe Point and<br>
&gt; &gt; &nbsp;Description is given for each event hook.<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;Group1:<br>
&gt; &gt; &nbsp;It contains 15 event hooks, which are used to probe Client-side<br>
&gt; &gt; &nbsp;NFS procedures.<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.read_setup<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_proc_read_setup,nfs3_proc_read_setup,<br>
&gt; &gt; nfs4_proc_read_setup<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Setup a rpc task to prepare for reading<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.read_done<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_proc_read_done,nfs3_proc_read_done,<br>
&gt; &gt; &nbsp;nfs4_proc_read_done<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Fires when receive a read reply from server,it is used to<br>
&gt; &gt; &nbsp;refresh the inode on client<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevnet.nfs.proc.read<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_proc_read,nfs3_proc_read,nfs4_proc_read<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Send a read operation to server,and refresh local inode after<br>
&gt; &gt; &nbsp;receive reply from server<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.write_setup<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; nfs_proc_write_setup,nfs3_proc_write_setup,nfs4_proc_write_setup<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_proc_write,nfs3_proc_write,nfs4_proc_write<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Send a write operation to server<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.write_done<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_write_done,nfs3_write_done,nfs4_write_done<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Fires when receive a write reply from server,it is used to<br>
&gt; &gt; &nbsp;refresh the inode on client<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.open<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_open<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Allocate file read/write context information<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.release<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_release<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Release file read/write context information<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.proc.create<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_create<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Create a new file or dir on server<br>
&gt; &gt; _____________________________________________________________________<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;Group2:<br>
&gt; &gt; &nbsp;This group includes the event hooks which probe NFS address space<br>
&gt; &gt; &nbsp;operation related function.All the functions are common in NFSV2,<br>
&gt; &gt; &nbsp;NFSV3,NFSV4.<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.aops.readpage<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_readpage<br>
&gt; &gt; &nbsp;Description :<br>
&gt; &gt; &nbsp;Read the page ,only fires when a previous async read operation<br>
&gt; &gt; &nbsp;failed<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.aops.readpages<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_readpages<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Fires when in readahead way,read several pages once<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.aops.writepage<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_writepage<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Write an mapped page to the server<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.aops.writepages<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_writepages<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Write several dirty pages to the serve once<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.aops.prepare_write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;prepare_write<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Prepare a page for writing. Look for a request corresponding<br>
&gt; &gt; &nbsp;to the page. If there is one, and it belongs to another aops,<br>
&gt; &gt; &nbsp;we flush it out before we try to copy anything into the page.<br>
&gt; &gt; &nbsp;Also do the same if we find a request from an existing<br>
&gt; &gt; &nbsp;dropped page.<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfs.aops.commit_write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfs_commit_write<br>
&gt; &gt; &nbsp;Description :<br>
&gt; &gt; &nbsp;Update and possibly write a cached page of an NFS aops<br>
&gt; &gt; _____________________________________________________________________<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;====================== NFS Server Side Trace Hooks ==================<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;The following event hooks are used to traced nfs server activities.<br>
&gt; &gt; &nbsp;The event hooks are divided into three group.<br>
&gt; &gt;<br>
&gt; &gt; &nbsp;Group1:<br>
&gt; &gt; &nbsp;It contains one event hook,which probes nfsd_dispatch<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.dispatch<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_dispatch<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Decode the arguments received from client,call the procedure<br>
&gt; &gt; &nbsp;handler,encode the result<br>
&gt; &gt; ______________________________________________________________________<br>
&gt; &gt; &nbsp;Group2:<br>
&gt; &gt; &nbsp;It contains three event hooks.The functions probed will be called<br>
&gt; &gt; &nbsp;by related procedure handler. All the functions are common in NFSV2,<br>
&gt; &gt; &nbsp;NFSV3,NFSV4<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.read<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_read<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;It does the &quot;real&quot; work of read<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_write<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;It does the &quot;real &quot; work of write<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.open<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_open<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Open an existing file or directory.<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.close<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_close<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Close an existing file or directory<br>
&gt; &gt; _____________________________________________________________________<br>
&gt; &gt; &nbsp;Group3:<br>
&gt; &gt; &nbsp;It contains eight event hooks,which probe procedure handlers.<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc2.read<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_proc_read<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Read data from file (NFSV2)<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc3.read<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd3_proc_read<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Read data from file (NFSV3)<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc4.read<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd4_read<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Check stateid and prepare for reading<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc2.write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd_proc_write<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Write data to file (NFSV2)<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.pro3.write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd3_proc_write<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Write data to file (NFSV3)<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc4.write<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd4_write<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Check stateid and write data to file<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc4.open<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd4_open<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Check stateid and open file<br>
&gt; &gt; ---------------------------------------------------------------------<br>
&gt; &gt; &nbsp;addevent.nfsd.proc4.compound<br>
&gt; &gt; &nbsp;Probe Point:<br>
&gt; &gt; &nbsp;nfsd4_proc_compound<br>
&gt; &gt; &nbsp;Description:<br>
&gt; &gt; &nbsp;Call different procedures according to client request<br>
&gt; &gt;<br>
&gt; &gt; -------------------------------------------------------------------------<br>
&gt; &gt; Take Surveys. Earn Cash. Influence the Future of IT<br>
&gt; &gt; Join SourceForge.net's Techsay panel and you'll get the chance to share your<br>
&gt; &gt; opinions on IT &amp; business topics through brief surveys -- and earn cash<br>
&gt; &gt; <a href="http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV">http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV</a><br>
&gt; &gt;<br>
&gt; &gt; _______________________________________________<br>
&gt; &gt; NFS maillist &nbsp;- &nbsp;NFS@lists.sourceforge.net<br>
&gt; &gt; <a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; <br>
&gt; <br>
&gt; -- <br>
&gt; &quot;We who cut mere stones must always be envisioning cathedrals&quot;<br>
&gt; &nbsp; &nbsp;-- Quarry worker's creed<br>
</tt></body></html>
--0__=C7BBFB2ADF8128828f9e8a93df938690918cC7BBFB2ADF812882--



--===============0062673653==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0062673653==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0062673653==--
