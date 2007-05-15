From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 15 May 2007 11:57:52 -0500
Message-ID: <4649E690.1050803@amd.com>
References: <4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com> <462CFC92.2080201@amd.com>
	<463B97E6.4030009@amd.com>
	<1178314889.6533.19.camel@heimdal.trondhjem.org>
	<1178379473.4559.24.camel@raven.themaw.net>
	<1178385472.6561.43.camel@heimdal.trondhjem.org>
	<20070514131743.GG31764@petra.dvoda.cz>
	<1179149048.6858.5.camel@heimdal.trondhjem.org>
	<1179153555.3811.57.camel@raven.themaw.net>
	<1179157631.6474.8.camel@heimdal.trondhjem.org>
	<1179158812.3811.68.camel@raven.themaw.net>
	<17992.58783.827023.697258@notabene.brown>
	<1179184319.6467.7.camel@heimdal.trondhjem.org>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	nfs@lists.sourceforge.net, Ian Kent <raven@themaw.net>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho0ed-0007zk-Er
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 10:17:43 -0700
Received: from outbound-dub.frontbridge.com ([213.199.154.16]
	helo=outbound4-dub-R.bigfish.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ho0ee-0003dE-6q
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 10:17:46 -0700
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

I admit to being biased representing what people's assumptions are.

My (main) assumptions of the default behavior of NFS exports and 
filesystems had nothing to do with cache consistency; they were based on 
"what the heck is the 'best' way to manage filesystems and NFS exports 
of petabytes of data that are grouped in large RAID aggregates?"

A "typical" NFS server (for us) has the ~following characteristics:

* 40 TB of data
* 5 RAID dual parity Aggregates
* 36 Volumes
* 83 Qtrees

The volumes are roughly equivalent to what NFS views as the "filesystem" 
export/superblock.  Volumes are sized/created for best performance 
across the disk/network/backplane subsystem.  Within volumes, qtrees(1) 
are created to administer quotas, data ownership, etc.  The qtrees are 
what are mounted by automount and the compute cluster with (potentially) 
different NFS mount options.

Raise the "typical" NFS server ^few powers for the administrative 
headache of an enterprise environment.

This is my biased point of view, offered up for informational purposes only.

Thanks,

--Greg


(1) Qtrees are logical divisions of data structures that can be managed 
individually.  The data space allocation of a qtree can be dynamically 
sized at will and without interruption to the user community.  With the 
advent of flexvols this feature is available for volumes however this is 
a recent feature.  One of the beneficial features of exports on the 
filer side is nested exports.  Most exports can be handled at the volume 
level consistently with only exceptions exported individually.  We do 
not make the practice of individually exporting every qtree.

> In fact, if you mounted the _same_ directory twice, then the default was
> always 'sharedcache'.
> 
> So all we did in 2.6.18, was to make a consistent set of rules for how
> this works.
> 
> The default should therefore remain 'sharedcache', preferably returning
> an error if the user tries to mix metaphors.
> 
> Cheers
>   Trond
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 

-- 
----------------------------------------------------------------------
Greg Baker                                         512-602-3287 (work)
gregory.baker@amd.com                              512-602-6970 (fax)
5204 E. Ben White Blvd MS 625                      512-555-1212 (info)
Austin, TX 78741




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
