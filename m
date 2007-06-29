From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of NFS over IPv6
Date: Fri, 29 Jun 2007 18:01:55 -0400
Message-ID: <46858153.8060109@oracle.com>
References: <20070629123747.GA1034@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020100090904010200040507"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4OZG-000740-8S
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 15:03:54 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I4OZI-0000Vk-Bx
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 15:03:57 -0700
In-Reply-To: <20070629123747.GA1034@uio.no>
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
--------------020100090904010200040507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steinar H. Gunderson wrote:
> What's the current status of NFS over IPv6 in Linux? There are HOWTOs out
> there, but most patches seem to be against old kernel versions, and
> completely unable to run both client and server from the same kernel tree.
> Additionally, I see mentions of replacements for portmap, but no clear
> upstream URL or updated versions anywhere. Also, there seems to be a separate
> git tree maintained by Chuck Lever, but gitweb hides any special patches it
> might have in tons of upstream patches.
> 
> I'd very much like to be able to sew all of this together at some point,
> but it's very hard to get a decent overview of it all. Does anyone have a
> "current status" or "plans for the near feature" summary?

I have some patches that add IPv6 support in the RPC client.  The server 
is more complicated (how to deal with address-based export rules, and so 
on).  There hasn't been much progress on the server side, but I think 
Bull is still working on that.

There are some patches for the NFS client, but we need to have both RPC 
client and server support for NFSv4 callback and NLM to work over IPv6 
(required for even a complete client implementation).

At this very moment I'm working on implementing mount option parsing in 
the kernel so we can easily add IPv6 addressing support to the NFS mount 
interface (among other improvements this will enable).

Steve Dickson has added Bull's rpcbind (replacement for portmap) to 
Fedora 7, but there is some disagreement about whether to use a complete 
replacement, like rpcbind, or whether to add the needed support to the 
existing portmap code, in general.

Bull has announced a test plan for user-space RPC libraries, although I 
haven't had a moment to look through it.  Bull should be providing 
testing resources once we have all of this integrated.

While there is some interest in IPv6 among some of Linux's corporate 
sponsors, there really isn't an overwhelming "killer" requirement for 
IPv6, so there isn't much motivation to get all this completed.  I have 
to admit I'm pretty burned out on all this because of how complicated it 
has all become.  I'd be happy if someone stepped forward and volunteered 
to help or take over the integration.

--------------020100090904010200040507
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


--------------020100090904010200040507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------020100090904010200040507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020100090904010200040507--
