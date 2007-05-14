From: Martin Knoblauch <spamtrap@knobisoft.de>
Subject: Re: Strange performance problems between Linux client and
	Sun/Solaris-10 Server with SAM-FS
Date: Mon, 14 May 2007 09:45:51 -0700 (PDT)
Message-ID: <26191.17882.qm@web32610.mail.mud.yahoo.com>
References: <758936.68723.qm@web32601.mail.mud.yahoo.com>
Reply-To: spamtrap@knobisoft.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HndgL-0002ku-3n
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:45:57 -0700
Received: from web32610.mail.mud.yahoo.com ([68.142.207.237])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HndgM-0003Lm-7u
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:46:00 -0700
In-Reply-To: <758936.68723.qm@web32601.mail.mud.yahoo.com>
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

>At 10:20 AM 5/14/2007, Martin Knoblauch wrote:
>> not sure whether I should feel stupid. Inspecting the tcpdump log
>>(snippet attached), I see a lot of "reply ERR 1448" packets coming 
from
>>the Sun. Which of course could explain a few things.
>
>Can you turn up the tcpdump reporting to show more NFS layer decoding?
>The "1448" is just the packet length at this level (which is a bit odd

>in
>itself - why such a large reply?), not the error code.
Hi Tom,

 How to turn NFS reporting up? "-vvv" does not give any more info?

 I looked at the source to tcpdump/print-nfs.c. The "1448" is just the
length. The difference between "ok" and "ERR" is the value of the
SUNRPC_MSG_ACCEPTED bit in "rp->rm_reply.rp_stat".

>>12:11:03.201366 IP (tos 0x0, ttl  61, id 42986, offset 0, flags [DF],

>>proto: TCP (6), length: 1500) 160.50.118.37.2049 > 
>>160.50.204.58.1090741696: reply ok 1448
>>12:11:03.201442 IP (tos 0x0, ttl  61, id 42987, offset 0, flags [DF],

>>proto: TCP (6), length: 1500) 160.50.118.37.2049 > 
>>160.50.204.58.1076887552: reply ERR 1448
>>...
>
>Tom.


------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
