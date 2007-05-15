From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 15 May 2007 09:58:07 -0400
Message-ID: <4649BC6F.2010906@oracle.com>
References: <4627B3DD.5050409@amd.com>	<1177007479.6623.14.camel@heimdal.trondhjem.org>	<4627D303.8060009@amd.com>	<1177020662.6628.30.camel@heimdal.trondhjem.org>	<4627EBFC.2090704@amd.com>	<462CFC92.2080201@amd.com>
	<463B97E6.4030009@amd.com>	<1178314889.6533.19.camel@heimdal.trondhjem.org>	<1178379473.4559.24.camel@raven.themaw.net>	<1178385472.6561.43.camel@heimdal.trondhjem.org>	<20070514131743.GG31764@petra.dvoda.cz>	<1179149048.6858.5.camel@heimdal.trondhjem.org>	<1179153555.3811.57.camel@raven.themaw.net>	<1179157631.6474.8.camel@heimdal.trondhjem.org>	<1179158812.3811.68.camel@raven.themaw.net>	<17992.58783.827023.697258@notabene.brown>
	<1179184319.6467.7.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090300020709060902030002"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Ian Kent <raven@themaw.net>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnxZc-0002EN-I9
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:00:24 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnxZd-0005UK-SK
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:00:23 -0700
In-Reply-To: <1179184319.6467.7.camel@heimdal.trondhjem.org>
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
--------------090300020709060902030002
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Disclaimer:

As Trond knows, I don't like the current "shared cache" implementation, 
even given the security issue of mounting the same file system with 
AUTH_SYS and AUTH_GSS.

See response below.

Trond Myklebust wrote:
> On Tue, 2007-05-15 at 08:41 +1000, Neil Brown wrote:
>> I think "shared" is an important concept to have in there as it is
>> sharing the cache, the connection and the options.  For consistency
>> with other options, I would have an optional "no" at the front to
>> invert the flag.  Current nfs options don't have punctuation, so I
>> would probably go for something like:
>>        -o  [no]sharedcache
>>        -o  [no]shareconnection 
>>
>> Then comes the question of what the default should be.
>> The original default was nosharedcache, but the more recent default
>> has been sharedcache.   In hindsight it would have been better not to
>> change the default, but things are always much clearer in hindsight.
>>
>> I would lean towards restoring the default to nosharedcache, and
>> having to explicitly request sharedcache if you want that, and are
>> happy to have the same mount option enforced on all sharing mounts.
> 
> I disagree with that. The default was changed for a very good reason,
> namely that people were making assumptions that were wrong: i.e. that
> the cache remains consistent when you change the ro/rw flag or try to
> mount a subdirectory.
> In fact, if you mounted the _same_ directory twice, then the default was
> always 'sharedcache'.
> 
> So all we did in 2.6.18, was to make a consistent set of rules for how
> this works.
> 
> The default should therefore remain 'sharedcache', preferably returning
> an error if the user tries to mix metaphors.

There have always been reasonable use cases (OK, well, reasonable to me 
anyway) for having completely separate options and caches for each NFS 
mount.  Another way to look at this is that "sharedcache" is really 
giving you "mount --bind" and not just a "mount".  Therefore all this 
can be mimicked in user space.

Just kicking it out there: why not revert the kernel back to the 
previous state of affairs where "nosharedcache" was the default, and 
then let user space handle sharing or not sharing, documenting clearly 
what the implications are in the mount(8) or nfs(5) man pages?  User 
space is smart enough to emit a warning about mixing security flavors, 
for instance, as suggested above.

--------------090300020709060902030002
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


--------------090300020709060902030002
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090300020709060902030002
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090300020709060902030002--
