From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: need info on IPv6 support for NFS in RHEL and SLES	distros
Date: Wed, 29 Aug 2007 17:16:43 -0400
Message-ID: <46D5E23B.5080305@oracle.com>
References: <3DFE68BCB5D6994994AA6CB1EC581EA30411E61E@qcaexc02.asiapacific.cpqcorp.net>	<46D59C8F.8070508@oracle.com>
	<20070829210828.GA21877@uio.no>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070308040007050906090008"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUvw-0007k3-6w
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:18:40 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQUw0-0003lS-Eo
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:18:44 -0700
In-Reply-To: <20070829210828.GA21877@uio.no>
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
--------------070308040007050906090008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steinar H. Gunderson wrote:
> On Wed, Aug 29, 2007 at 12:19:27PM -0400, Chuck Lever wrote:
>> No Linux distribution contains IPv6 support for NFS right now.  The 
>> implementation is still being developed.
> 
> Speaking of which, what's missing now? I see text-based mounts, client-side
> IPv6 RPC and server-side transport switch (of which the first two are already
> in mainline, and the last seems to be on its way) -- my impression was that
> these are all important building blocks. I guess nfs-utils will also need
> some patching, and an IPv6 transport will be needed for plugging into the
> server side transport switch, but after that?

This may be impolitic to say in public, but the transport switch APIs 
aren't really needed for IPv6.  It just seemed easier to apply the IPv6 
changes to the transport switch work than the other way around.

On the client, we will need IPv6 addressing support from the mount.nfs 
command through to the network transport implementations.  We have 
pieces of that implemented.

The client needs to have NFSv4 callback support and lockd support for 
IPv6, so we need RPC server support for IPv6 -- that's nearing 
completion once we have the ip_map cache fixed up to support IPv6 addresses.

On the server, we need support for mountd and rpcbind, and support build 
into the NFS server itself.  I understand Bull is still working on the 
server changes, and SteveD has added rpcbind to Fedora and is making it 
robust.

In addition I think we will need to examine exportfs and anything else 
on the server side to check for any dependence on address format.

To finish, Bull has been testing parts of this work as it has been 
developed, and will need to continue testing it after it has all been 
integrated.  Interoperability testing between Linux, Solaris, and AIX 
are on the list.

--------------070308040007050906090008
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070308040007050906090008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------070308040007050906090008
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070308040007050906090008--
