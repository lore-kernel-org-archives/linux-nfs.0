From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [ltc-perf] draft of nfs event hook
Date: Wed, 26 Jul 2006 09:50:42 -0400
Message-ID: <76bd70e30607260650j726cb7f1mb7ff812ae5d54bd8@mail.gmail.com>
References: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: varap@us.ibm.com, ltc-perf@linux.ibm.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5l1h-0001MK-CI
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 08:10:21 -0700
Received: from nf-out-0910.google.com ([64.233.182.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5l1g-0006mr-Qr
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 08:10:21 -0700
Received: by nf-out-0910.google.com with SMTP id m19so700956nfc
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 08:10:18 -0700 (PDT)
To: "Xue Peng Li" <xuepengl@cn.ibm.com>
In-Reply-To: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
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

Xue Peng ---

I've only glanced at your specification, but it occurs to me that it
would be helpful for reviewers to understand your intent of adding the
hooks where you did.  Do you have a design document, even a short one?
 Or can you discuss your decisions on the list with us?

For example, why hook all three of "setup" "read/write" and "done" ?

And, what value do you hope these hooks will add over and above the
performance metrics that I added in 2.6.17 ?  We see the SystemTap
hooks as an opportunity to make more specialized (and potentially more
run-time expensive) observations than the performance metrics.

Are there other file systems that have hooks in them?  Did you add
hooks in conventional/standard places for all file systems?

Thanks!

On 7/26/06, Xue Peng Li <xuepengl@cn.ibm.com> wrote:
>
>
>
> Hi folks,
>
>  I am working on NFS trace hooks for SystemTap/LKET. These trace
>  hooks could be used for performance analyzing which will trace both
>  NFS client and server side activities.
>
>  At the first step I need make sure that the trace hooks I defined
>  are appropriate and every trace hook probes the right places inside
>  the Kernel. So I will be appreciated if you could help me review the
>  following trace hooks.
>
>
>  Thanks
>
>  ======================== NFS Client Side Trace Hooks =================
>
>  The following event hooks are used to trace nfs client activities.
>  These event hooks are divided into two groups. Probe Point and
>  Description is given for each event hook.
>
>  Group1:
>  It contains 15 event hooks, which are used to probe Client-side
>  NFS procedures.
> ---------------------------------------------------------------------
>  addevent.nfs.proc.read_setup
>  Probe Point:
>  nfs_proc_read_setup,nfs3_proc_read_setup,
> nfs4_proc_read_setup
>  Description:
>  Setup a rpc task to prepare for reading
> ---------------------------------------------------------------------
>  addevent.nfs.proc.read_done
>  Probe Point:
>  nfs_proc_read_done,nfs3_proc_read_done,
>  nfs4_proc_read_done
>  Description:
>  Fires when receive a read reply from server,it is used to
>  refresh the inode on client
> ---------------------------------------------------------------------
>  addevnet.nfs.proc.read
>  Probe Point:
>  nfs_proc_read,nfs3_proc_read,nfs4_proc_read
>  Description:
>  Send a read operation to server,and refresh local inode after
>  receive reply from server
> ---------------------------------------------------------------------
>  addevent.nfs.proc.write_setup
>  Probe Point:
> nfs_proc_write_setup,nfs3_proc_write_setup,nfs4_proc_write_setup
>  Description:
> ---------------------------------------------------------------------
>  addevent.nfs.proc.write
>  Probe Point:
>  nfs_proc_write,nfs3_proc_write,nfs4_proc_write
>  Description:
>  Send a write operation to server
> ---------------------------------------------------------------------
>  addevent.nfs.proc.write_done
>  Probe Point:
>  nfs_write_done,nfs3_write_done,nfs4_write_done
>  Description:
>  Fires when receive a write reply from server,it is used to
>  refresh the inode on client
> ---------------------------------------------------------------------
>  addevent.nfs.proc.open
>  Probe Point:
>  nfs_open
>  Description:
>  Allocate file read/write context information
> ---------------------------------------------------------------------
>  addevent.nfs.proc.release
>  Probe Point:
>  nfs_release
>  Description:
>  Release file read/write context information
> ---------------------------------------------------------------------
>  addevent.nfs.proc.create
>  Probe Point:
>  nfs_create
>  Description:
>  Create a new file or dir on server
> _____________________________________________________________________
>
>  Group2:
>  This group includes the event hooks which probe NFS address space
>  operation related function.All the functions are common in NFSV2,
>  NFSV3,NFSV4.
> ---------------------------------------------------------------------
>  addevent.nfs.aops.readpage
>  Probe Point:
>  nfs_readpage
>  Description :
>  Read the page ,only fires when a previous async read operation
>  failed
> ---------------------------------------------------------------------
>  addevent.nfs.aops.readpages
>  Probe Point:
>  nfs_readpages
>  Description:
>  Fires when in readahead way,read several pages once
> ---------------------------------------------------------------------
>  addevent.nfs.aops.writepage
>  Probe Point:
>  nfs_writepage
>  Description:
>  Write an mapped page to the server
> ---------------------------------------------------------------------
>  addevent.nfs.aops.writepages
>  Probe Point:
>  nfs_writepages
>  Description:
>  Write several dirty pages to the serve once
> ---------------------------------------------------------------------
>  addevent.nfs.aops.prepare_write
>  Probe Point:
>  prepare_write
>  Description:
>  Prepare a page for writing. Look for a request corresponding
>  to the page. If there is one, and it belongs to another aops,
>  we flush it out before we try to copy anything into the page.
>  Also do the same if we find a request from an existing
>  dropped page.
> ---------------------------------------------------------------------
>  addevent.nfs.aops.commit_write
>  Probe Point:
>  nfs_commit_write
>  Description :
>  Update and possibly write a cached page of an NFS aops
> _____________________________________________________________________
>
>
>  ====================== NFS Server Side Trace Hooks ==================
>
>  The following event hooks are used to traced nfs server activities.
>  The event hooks are divided into three group.
>
>  Group1:
>  It contains one event hook,which probes nfsd_dispatch
> ---------------------------------------------------------------------
>  addevent.nfsd.dispatch
>  Probe Point:
>  nfsd_dispatch
>  Description:
>  Decode the arguments received from client,call the procedure
>  handler,encode the result
> ______________________________________________________________________
>  Group2:
>  It contains three event hooks.The functions probed will be called
>  by related procedure handler. All the functions are common in NFSV2,
>  NFSV3,NFSV4
> ---------------------------------------------------------------------
>  addevent.nfsd.read
>  Probe Point:
>  nfsd_read
>  Description:
>  It does the "real" work of read
> ---------------------------------------------------------------------
>  addevent.nfsd.write
>  Probe Point:
>  nfsd_write
>  Description:
>  It does the "real " work of write
> ---------------------------------------------------------------------
>  addevent.nfsd.open
>  Probe Point:
>  nfsd_open
>  Description:
>  Open an existing file or directory.
> ---------------------------------------------------------------------
>  addevent.nfsd.close
>  Probe Point:
>  nfsd_close
>  Description:
>  Close an existing file or directory
> _____________________________________________________________________
>  Group3:
>  It contains eight event hooks,which probe procedure handlers.
> ---------------------------------------------------------------------
>  addevent.nfsd.proc2.read
>  Probe Point:
>  nfsd_proc_read
>  Description:
>  Read data from file (NFSV2)
> ---------------------------------------------------------------------
>  addevent.nfsd.proc3.read
>  Probe Point:
>  nfsd3_proc_read
>  Description:
>  Read data from file (NFSV3)
> ---------------------------------------------------------------------
>  addevent.nfsd.proc4.read
>  Probe Point:
>  nfsd4_read
>  Description:
>  Check stateid and prepare for reading
> ---------------------------------------------------------------------
>  addevent.nfsd.proc2.write
>  Probe Point:
>  nfsd_proc_write
>  Description:
>  Write data to file (NFSV2)
> ---------------------------------------------------------------------
>  addevent.nfsd.pro3.write
>  Probe Point:
>  nfsd3_proc_write
>  Description:
>  Write data to file (NFSV3)
> ---------------------------------------------------------------------
>  addevent.nfsd.proc4.write
>  Probe Point:
>  nfsd4_write
>  Description:
>  Check stateid and write data to file
> ---------------------------------------------------------------------
>  addevent.nfsd.proc4.open
>  Probe Point:
>  nfsd4_open
>  Description:
>  Check stateid and open file
> ---------------------------------------------------------------------
>  addevent.nfsd.proc4.compound
>  Probe Point:
>  nfsd4_proc_compound
>  Description:
>  Call different procedures according to client request
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys -- and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>


-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
