From: Juan Gomez <juang@us.ibm.com>
Subject: FreeBSD -> Linux locking problems (Robert Kellner)
Date: Mon, 4 Nov 2002 13:08:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFD4C20A72.8460A8EF-ON87256C67.0073E4E1@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 188oS6-0003bN-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 13:08:06 -0800
Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e33.co.us.ibm.com (8.12.2/8.12.2) with ESMTP id gA4L7xGx056056
	for <nfs@lists.sourceforge.net>; Mon, 4 Nov 2002 16:07:59 -0500
Received: from d03nm694.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay04.boulder.ibm.com (8.12.3/NCO/VER6.4) with ESMTP id gA4LAAwv087442
	for <nfs@lists.sourceforge.net>; Mon, 4 Nov 2002 14:10:10 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>





 Robert,

I would say you try to trace the lockd/statd activity in your Linux box.
Recent versions of statd shipped with readhat are broken so this may have
some influence.
to trace you can run statd with -F -d options to get statd log and you can
do echo dec(0xFFFF) > /proc/sys/sunrpc/nlm_debug (which will put messages
in /var/log/messages
If you post those logs here we would be able to see whats going on in your
case.

Same in the FreeBSD side

Juan



|---------+--------------------------------->
|         |           nfs-request@lists.sour|
|         |           ceforge.net           |
|         |           Sent by:              |
|         |           nfs-admin@lists.source|
|         |           forge.net             |
|         |                                 |
|         |                                 |
|         |           11/04/02 12:18 PM     |
|         |           Please respond to nfs |
|         |                                 |
|---------+--------------------------------->
  >------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                  |
  |       To:       nfs@lists.sourceforge.net                                                                        |
  |       cc:                                                                                                        |
  |       Subject:  NFS digest, Vol 1 #1216 - 3 msgs                                                                 |
  |                                                                                                                  |
  |                                                                                                                  |
  >------------------------------------------------------------------------------------------------------------------|



Send NFS mailing list submissions to
             nfs@lists.sourceforge.net

To subscribe or unsubscribe via the World Wide Web, visit
             https://lists.sourceforge.net/lists/listinfo/nfs
or, via email, send a message with subject or body 'help' to
             nfs-request@lists.sourceforge.net

You can reach the person managing the list at
             nfs-admin@lists.sourceforge.net

When replying, please edit your Subject line so it is more specific
than "Re: Contents of NFS digest..."


Today's Topics:

   1. FreeBSD -> Linux locking problems (Robert Kellner)
   2. RE: 2.4.20-rc1 NFS/TCP client (still) hangs running
       dbench  2.0 (Andrew Ryan)

--__--__--

Message: 1
Date: Mon, 4 Nov 2002 17:36:26 +0100
From: Robert Kellner <skyywalk@btcips73x1.cip.uni-bayreuth.de>
To: nfs@lists.sourceforge.net
Subject: [NFS] FreeBSD -> Linux locking problems

Hello,

I am using a FreeBSD System as server for nfs and nis for
linux clients.
Unfortunately nfs-file locking does not work although
nlockmgr and rpc.statd are running on both systems.

The FAQ says nothing about troubles with FreeBSD and Linux
concerning locks.

Does anybody know about this Problem and/or how to solve it?

Greetings,

Robert


--__--__--

Message: 2
Date: Mon, 04 Nov 2002 08:51:00 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
From: Andrew Ryan <andrewr@nam-shub.com>
Subject: RE: [NFS] 2.4.20-rc1 NFS/TCP client (still) hangs running
  dbench  2.0
Cc: nfs@lists.sourceforge.net

At 09:05 AM 11/3/02 -0800, Lever, Charles wrote:

>did you try the xprt_write_space patch?  that fixes a real problem,
>and addresses the root cause of the high retransmission counts you see.

Has this patch been posted on Trond's site? If so can you refer me to it?
It's not marked under the 2.4.20 directory. If it hasn't been posted, can
it be?


>call_start is available in Trond's NFS_ALL patch for now.  i think 2.4.20
>is closed for changes like this.

OK, fair enough.




--__--__--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


End of NFS Digest





-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
