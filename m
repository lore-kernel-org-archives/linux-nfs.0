From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Strange performance problems between Linux client
 and	Sun/Solaris-10 Server with SAM-FS
Date: Mon, 14 May 2007 13:28:07 -0400
Message-ID: <46489C27.5040306@oracle.com>
References: <26191.17882.qm@web32610.mail.mud.yahoo.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080102030907080000080109"
Cc: nfs@lists.sourceforge.net
To: spamtrap@knobisoft.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HneMM-00072W-O5
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 10:29:22 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HneMN-0006GK-5z
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 10:29:25 -0700
In-Reply-To: <26191.17882.qm@web32610.mail.mud.yahoo.com>
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

This is a multi-part message in MIME format.
--------------080102030907080000080109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Martin Knoblauch wrote:
>> At 10:20 AM 5/14/2007, Martin Knoblauch wrote:
>>> not sure whether I should feel stupid. Inspecting the tcpdump log
>>> (snippet attached), I see a lot of "reply ERR 1448" packets coming 
> from
>>> the Sun. Which of course could explain a few things.
>> Can you turn up the tcpdump reporting to show more NFS layer decoding?
>> The "1448" is just the packet length at this level (which is a bit odd
> 
>> in
>> itself - why such a large reply?), not the error code.
> Hi Tom,
> 
>  How to turn NFS reporting up? "-vvv" does not give any more info?

Ensure that tcpdump is capturing whole frames.  By default it captures 
only 96 bytes of each Ethernet frame, which isn't enough to tell what is 
going on at the RPC or NFS layer.  Use:

   tcpdump -s0 -w/tmp/raw

to collect your data, then use WireShark, as Tom suggested to analyze 
the captured trace.

--------------080102030907080000080109
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------080102030907080000080109
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------080102030907080000080109
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080102030907080000080109--
