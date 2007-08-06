From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 06 Aug 2007 15:13:15 -0400
Message-ID: <46B772CB.1080906@oracle.com>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEAB@exchrdm.ad.xensource.com>	
	<46B74E5C.4060400@oracle.com> <46B755FE.1010909@oracle.com>
	<1186426710.6616.57.camel@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040505030806000806040406"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II825-0005Ej-Jz
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:14:25 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II828-0002s0-BB
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:14:29 -0700
In-Reply-To: <1186426710.6616.57.camel@localhost>
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
--------------040505030806000806040406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Mon, 2007-08-06 at 13:10 -0400, Chuck Lever wrote:
>> Even though an NFS client requests an NFS_FILE_SYNC write, the server 
>> still has the choice of returning something less, even NFS_UNSTABLE.  In 
>> general that's a rare occurrence, but is something I've seen in practice.
> 
> As Peter said, a server that return anything other than FILE_SYNC to a
> FILE_SYNC write request would be in clear violation of the description
> of WRITE semantics on page 51 of RFC1813:
> 
>       committed
>          The server should return an indication of the level of
>          commitment of the data and metadata via committed. If
>          the server committed all data and metadata to stable
>          storage, committed should be set to FILE_SYNC. If the
>          level of commitment was at least as strong as
>          DATA_SYNC, then committed should be set to DATA_SYNC.
>          Otherwise, committed must be returned as UNSTABLE. If
>          stable was FILE_SYNC, then committed must also be
>          FILE_SYNC: anything else constitutes a protocol
>          violation. If stable was DATA_SYNC, then committed may
>          be FILE_SYNC or DATA_SYNC: anything else constitutes a
>          protocol violation. If stable was UNSTABLE, then
>          committed may be either FILE_SYNC, DATA_SYNC, or
>          UNSTABLE.
> 
> I see no reason why we should care about supporting such a server.

I said nothing about whether the server should or should not return such 
a value.  I just said that it is a possibility, and that I have observed 
the behavior in the field.

The client, if it is a good implementation, needs to check for this 
possibility and throw an error in that case.

--------------040505030806000806040406
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------040505030806000806040406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040505030806000806040406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040505030806000806040406--
