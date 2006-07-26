From: Xue Peng Li <xuepengl@cn.ibm.com>
Subject: [ltc-perf] draft of nfs event hook
Date: Wed, 26 Jul 2006 17:13:09 +0800
Message-ID: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1890877600=="
Cc: varap@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5fQN-0006Ix-N1
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:11:28 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5fQN-0008LK-C8
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:11:28 -0700
Received: from ausmtp06.au.ibm.com ([202.81.18.155])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5fQI-0006oU-8n
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:11:24 -0700
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp06.au.ibm.com (8.13.6/8.13.6) with ESMTP id k6Q9Cds95619764
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 19:12:39 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id
	k6Q9EFui180822
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 19:14:18 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k6Q9AXnw009929
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 19:10:33 +1000
Received: from d23m0037.cn.ibm.com ([9.181.2.105])
	by d23av04.au.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6Q9ATnX008159
	for <nfs@lists.sourceforge.net>; Wed, 26 Jul 2006 19:10:31 +1000
To: ltc-perf@linux.ibm.com
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

--===============1890877600==
Content-type: multipart/alternative;
	Boundary="0__=C7BBFB24DFA2343D8f9e8a93df938690918cC7BBFB24DFA2343D"
Content-Disposition: inline

--0__=C7BBFB24DFA2343D8f9e8a93df938690918cC7BBFB24DFA2343D
Content-type: text/plain; charset=US-ASCII


Hi folks,

  I am working on NFS trace hooks for SystemTap/LKET. These trace
hooks could be used for performance analyzing which will trace both
NFS client and server side activities.

  At the first step I need make sure that the trace hooks I defined
are appropriate and every trace hook probes the right places inside
the Kernel. So I will be appreciated if you could help me review the
following trace hooks.


Thanks

======================== NFS Client Side Trace Hooks =================

The following event hooks are used to trace nfs client activities.
These event hooks are divided into two groups.  Probe Point and
Description is given for each event hook.

Group1:
 It contains 15 event hooks, which are used to probe Client-side
NFS procedures.
---------------------------------------------------------------------
addevent.nfs.proc.read_setup
  Probe Point:
       nfs_proc_read_setup,nfs3_proc_read_setup, nfs4_proc_read_setup
  Description:
      Setup a rpc task to prepare for reading
---------------------------------------------------------------------
addevent.nfs.proc.read_done
  Probe Point:
      nfs_proc_read_done,nfs3_proc_read_done,
      nfs4_proc_read_done
  Description:
      Fires when receive a read reply from server,it is used to
      refresh the inode on client
---------------------------------------------------------------------
addevnet.nfs.proc.read
  Probe Point:
      nfs_proc_read,nfs3_proc_read,nfs4_proc_read
 Description:
      Send a read operation to server,and refresh local inode after
       receive reply from server
---------------------------------------------------------------------
addevent.nfs.proc.write_setup
  Probe Point:
      nfs_proc_write_setup,nfs3_proc_write_setup,nfs4_proc_write_setup
  Description:
---------------------------------------------------------------------
addevent.nfs.proc.write
  Probe Point:
      nfs_proc_write,nfs3_proc_write,nfs4_proc_write
  Description:
      Send a write operation to server
---------------------------------------------------------------------
addevent.nfs.proc.write_done
  Probe Point:
      nfs_write_done,nfs3_write_done,nfs4_write_done
  Description:
      Fires when receive a write reply from server,it is used to
      refresh the inode on client
---------------------------------------------------------------------
addevent.nfs.proc.open
  Probe Point:
      nfs_open
  Description:
      Allocate file read/write context information
---------------------------------------------------------------------
addevent.nfs.proc.release
  Probe Point:
      nfs_release
  Description:
      Release file read/write context information
---------------------------------------------------------------------
addevent.nfs.proc.create
  Probe Point:
      nfs_create
  Description:
      Create  a new file or dir on server
_____________________________________________________________________

Group2:
  This group includes the event hooks which probe NFS address space
operation related function.All the functions are common in NFSV2,
NFSV3,NFSV4.
---------------------------------------------------------------------
addevent.nfs.aops.readpage
  Probe Point:
    nfs_readpage
  Description :
    Read the page ,only fires when a previous async read operation
    failed
---------------------------------------------------------------------
addevent.nfs.aops.readpages
  Probe Point:
    nfs_readpages
  Description:
     Fires when in readahead way,read several pages once
---------------------------------------------------------------------
addevent.nfs.aops.writepage
  Probe Point:
     nfs_writepage
  Description:
     Write an mapped page to the server
---------------------------------------------------------------------
addevent.nfs.aops.writepages
  Probe Point:
     nfs_writepages
  Description:
     Write several dirty pages to the serve once
---------------------------------------------------------------------
addevent.nfs.aops.prepare_write
   Probe Point:
       prepare_write
   Description:
       Prepare a page for writing. Look for a request corresponding
       to the page. If there is one, and it belongs to another aops,
       we flush it out before we try to copy anything into the page.
       Also do the same if we find a request from an existing
       dropped page.
---------------------------------------------------------------------
addevent.nfs.aops.commit_write
  Probe Point:
      nfs_commit_write
  Description :
      Update and possibly write a cached page of an NFS aops
_____________________________________________________________________


====================== NFS Server Side Trace Hooks ==================

The following event hooks are used to traced nfs server activities.
The event hooks are divided into three group.

Group1:
  It contains one event hook,which probes nfsd_dispatch
---------------------------------------------------------------------
addevent.nfsd.dispatch
  Probe Point:
   nfsd_dispatch
  Description:
   Decode the arguments received from client,call the procedure
   handler,encode the result
______________________________________________________________________
Group2:
  It contains three event hooks.The functions probed will be called
  by related procedure handler. All the functions are common in NFSV2,
  NFSV3,NFSV4
---------------------------------------------------------------------
addevent.nfsd.read
  Probe Point:
    nfsd_read
  Description:
    It does the "real" work of read
---------------------------------------------------------------------
addevent.nfsd.write
  Probe Point:
    nfsd_write
 Description:
    It does the "real " work of write
---------------------------------------------------------------------
addevent.nfsd.open
  Probe Point:
    nfsd_open
  Description:
    Open an existing file or directory.
---------------------------------------------------------------------
addevent.nfsd.close
   Probe Point:
    nfsd_close
  Description:
    Close an existing file or directory
_____________________________________________________________________
Group3:
    It contains eight event hooks,which probe procedure handlers.
---------------------------------------------------------------------
addevent.nfsd.proc2.read
  Probe Point:
   nfsd_proc_read
  Description:
   Read data from file (NFSV2)
---------------------------------------------------------------------
addevent.nfsd.proc3.read
  Probe Point:
   nfsd3_proc_read
  Description:
   Read data from file (NFSV3)
---------------------------------------------------------------------
addevent.nfsd.proc4.read
  Probe Point:
    nfsd4_read
  Description:
    Check stateid and prepare for reading
---------------------------------------------------------------------
addevent.nfsd.proc2.write
  Probe Point:
   nfsd_proc_write
  Description:
   Write data to file (NFSV2)
---------------------------------------------------------------------
addevent.nfsd.pro3.write
  Probe Point:
   nfsd3_proc_write
  Description:
   Write data to file (NFSV3)
---------------------------------------------------------------------
addevent.nfsd.proc4.write
  Probe Point:
    nfsd4_write
  Description:
    Check stateid and write data to file
---------------------------------------------------------------------
addevent.nfsd.proc4.open
  Probe Point:
    nfsd4_open
  Description:
    Check stateid and open file
---------------------------------------------------------------------
addevent.nfsd.proc4.compound
  Probe Point:
   nfsd4_proc_compound
  Description:
   Call different procedures according to client request
--0__=C7BBFB24DFA2343D8f9e8a93df938690918cC7BBFB24DFA2343D
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Hi folks,<br>
<br>
  I am working on NFS trace hooks for SystemTap/LKET. These trace <br>
hooks could be used for performance analyzing which will trace both <br>
NFS client and server side activities. <br>
<br>
  At the first step I need make sure that the trace hooks I defined <br>
are appropriate and every trace hook probes the right places inside <br>
the Kernel. So I will be appreciated if you could help me review the<br>
following trace hooks.<br>
<br>
<br>
Thanks<br>
<br>
======================== NFS Client Side Trace Hooks =================<br>
<br>
The following event hooks are used to trace nfs client activities.<br>
These event hooks are divided into two groups.  Probe Point and <br>
Description is given for each event hook.<br>
<br>
Group1:<br>
 It contains 15 event hooks, which are used to probe Client-side <br>
NFS procedures. <br>
---------------------------------------------------------------------<br>
addevent.nfs.proc.read_setup<br>
  Probe Point:<br>
       nfs_proc_read_setup,nfs3_proc_read_setup, nfs4_proc_read_setup<br>
  Description:<br>
      Setup a rpc task to prepare for reading<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.read_done<br>
  Probe Point:<br>
      nfs_proc_read_done,nfs3_proc_read_done,<br>
      nfs4_proc_read_done<br>
  Description:<br>
      Fires when receive a read reply from server,it is used to <br>
      refresh the inode on client<br>
--------------------------------------------------------------------- <br>
addevnet.nfs.proc.read<br>
  Probe Point:<br>
      nfs_proc_read,nfs3_proc_read,nfs4_proc_read<br>
 Description:<br>
      Send a read operation to server,and refresh local inode after<br>
       receive reply from server<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.write_setup<br>
  Probe Point:<br>
      nfs_proc_write_setup,nfs3_proc_write_setup,nfs4_proc_write_setup <br>
  Description:<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.write<br>
  Probe Point:<br>
      nfs_proc_write,nfs3_proc_write,nfs4_proc_write <br>
  Description:<br>
      Send a write operation to server<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.write_done<br>
  Probe Point:<br>
      nfs_write_done,nfs3_write_done,nfs4_write_done<br>
  Description:<br>
      Fires when receive a write reply from server,it is used to<br>
      refresh the inode on client<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.open<br>
  Probe Point:<br>
      nfs_open<br>
  Description:<br>
      Allocate file read/write context information<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.release<br>
  Probe Point:<br>
      nfs_release<br>
  Description:<br>
      Release file read/write context information<br>
--------------------------------------------------------------------- <br>
addevent.nfs.proc.create<br>
  Probe Point:<br>
      nfs_create<br>
  Description:<br>
      Create  a new file or dir on server<br>
_____________________________________________________________________<br>
<br>
Group2:<br>
  This group includes the event hooks which probe NFS address space <br>
operation related function.All the functions are common in NFSV2,<br>
NFSV3,NFSV4.  <br>
--------------------------------------------------------------------- <br>
addevent.nfs.aops.readpage<br>
  Probe Point:<br>
    nfs_readpage<br>
  Description :<br>
    Read the page ,only fires when a previous async read operation <br>
    failed<br>
--------------------------------------------------------------------- <br>
addevent.nfs.aops.readpages<br>
  Probe Point:<br>
    nfs_readpages<br>
  Description:<br>
     Fires when in readahead way,read several pages once<br>
--------------------------------------------------------------------- <br>
addevent.nfs.aops.writepage<br>
  Probe Point:<br>
     nfs_writepage<br>
  Description: <br>
     Write an mapped page to the server<br>
--------------------------------------------------------------------- <br>
addevent.nfs.aops.writepages<br>
  Probe Point:<br>
     nfs_writepages<br>
  Description:<br>
     Write several dirty pages to the serve once<br>
---------------------------------------------------------------------<br>
addevent.nfs.aops.prepare_write<br>
   Probe Point:<br>
       prepare_write<br>
   Description:<br>
       Prepare a page for writing. Look for a request corresponding <br>
       to the page. If there is one, and it belongs to another aops, <br>
       we flush it out before we try to copy anything into the page. <br>
       Also do the same if we find a request from an existing <br>
       dropped page.<br>
--------------------------------------------------------------------- <br>
addevent.nfs.aops.commit_write<br>
  Probe Point:<br>
      nfs_commit_write<br>
  Description :<br>
      Update and possibly write a cached page of an NFS aops<br>
_____________________________________________________________________ <br>
<br>
<br>
====================== NFS Server Side Trace Hooks ==================<br>
<br>
The following event hooks are used to traced nfs server activities.<br>
The event hooks are divided into three group. <br>
<br>
Group1:<br>
  It contains one event hook,which probes nfsd_dispatch <br>
---------------------------------------------------------------------<br>
addevent.nfsd.dispatch<br>
  Probe Point: <br>
   nfsd_dispatch<br>
  Description:<br>
   Decode the arguments received from client,call the procedure<br>
   handler,encode the result<br>
______________________________________________________________________ <br>
Group2:<br>
  It contains three event hooks.The functions probed will be called <br>
  by related procedure handler. All the functions are common in NFSV2,<br>
  NFSV3,NFSV4<br>
--------------------------------------------------------------------- <br>
addevent.nfsd.read<br>
  Probe Point:<br>
    nfsd_read<br>
  Description:<br>
    It does the &quot;real&quot; work of read <br>
--------------------------------------------------------------------- <br>
addevent.nfsd.write<br>
  Probe Point:<br>
    nfsd_write<br>
 Description:<br>
    It does the &quot;real &quot; work of write<br>
--------------------------------------------------------------------- <br>
addevent.nfsd.open<br>
  Probe Point:<br>
    nfsd_open<br>
  Description:<br>
    Open an existing file or directory.<br>
---------------------------------------------------------------------<br>
addevent.nfsd.close<br>
   Probe Point:<br>
    nfsd_close<br>
  Description:<br>
    Close an existing file or directory<br>
_____________________________________________________________________<br>
Group3:<br>
    It contains eight event hooks,which probe procedure handlers.<br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc2.read<br>
  Probe Point:<br>
   nfsd_proc_read<br>
  Description:<br>
   Read data from file (NFSV2)<br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc3.read<br>
  Probe Point:<br>
   nfsd3_proc_read<br>
  Description:<br>
   Read data from file (NFSV3)<br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc4.read<br>
  Probe Point:<br>
    nfsd4_read<br>
  Description:<br>
    Check stateid and prepare for reading <br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc2.write<br>
  Probe Point:<br>
   nfsd_proc_write<br>
  Description:<br>
   Write data to file (NFSV2)<br>
---------------------------------------------------------------------<br>
addevent.nfsd.pro3.write<br>
  Probe Point:<br>
   nfsd3_proc_write<br>
  Description:<br>
   Write data to file (NFSV3)<br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc4.write<br>
  Probe Point:<br>
    nfsd4_write<br>
  Description:<br>
    Check stateid and write data to file<br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc4.open<br>
  Probe Point:<br>
    nfsd4_open<br>
  Description:<br>
    Check stateid and open file<br>
---------------------------------------------------------------------<br>
addevent.nfsd.proc4.compound<br>
  Probe Point:<br>
   nfsd4_proc_compound<br>
  Description:<br>
   Call different procedures according to client request <br>
</body></html>
--0__=C7BBFB24DFA2343D8f9e8a93df938690918cC7BBFB24DFA2343D--



--===============1890877600==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1890877600==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1890877600==--
