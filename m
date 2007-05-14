From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Strange performance problems between Linux client and
 Sun/Solaris-10 Server with SAM-FS
Date: Mon, 14 May 2007 10:39:21 -0400
Message-ID: <EXNANE01bUf9Sp2WEnK000009e1@exnane01.hq.netapp.com>
References: <758936.68723.qm@web32601.mail.mud.yahoo.com>
	<295440.67356.qm@web32605.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hnbhu-0005Un-3u
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 07:39:26 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hnbhv-0001gA-S8
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 07:39:29 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l4EEdLIv020918
	for <nfs@lists.sourceforge.net>; Mon, 14 May 2007 07:39:21 -0700 (PDT)
In-Reply-To: <295440.67356.qm@web32605.mail.mud.yahoo.com>
References: <758936.68723.qm@web32601.mail.mud.yahoo.com>
	<295440.67356.qm@web32605.mail.mud.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 10:20 AM 5/14/2007, Martin Knoblauch wrote:
> not sure whether I should feel stupid. Inspecting the tcpdump log
>(snippet attached), I see a lot of "reply ERR 1448" packets coming from
>the Sun. Which of course could explain a few things.

Can you turn up the tcpdump reporting to show more NFS layer decoding?
The "1448" is just the packet length at this level (which is a bit odd in
itself - why such a large reply?), not the error code.

>12:11:03.201366 IP (tos 0x0, ttl  61, id 42986, offset 0, flags [DF], 
>proto: TCP (6), length: 1500) 160.50.118.37.2049 > 
>160.50.204.58.1090741696: reply ok 1448
>12:11:03.201442 IP (tos 0x0, ttl  61, id 42987, offset 0, flags [DF], 
>proto: TCP (6), length: 1500) 160.50.118.37.2049 > 
>160.50.204.58.1076887552: reply ERR 1448
>...

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
