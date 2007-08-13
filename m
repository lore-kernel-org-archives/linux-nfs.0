From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 09:27:28 -0400
Message-ID: <46C05C40.30707@redhat.com>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKZy1-0002h0-2p
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 06:28:21 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKZy5-000838-1l
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 06:28:25 -0700
In-Reply-To: <Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
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

Peter =C5strand wrote:
> On Fri, 3 Aug 2007, Peter Staubach wrote:
>
>> Attached is a patch to modify the NFS client code to support
>> 64 bit ino's, as appropriate for the system and the NFS
>> protocol version.
>>
>> The code basically just expand the NFS interfaces for routines
>> which handle ino's from using ino_t to u64 and then uses the
>> fileid in the nfs_inode instead of i_ino in the inode.  The
>
> This patch seems to overlap with =

> linux-2.6-nfs-64-bit-inode-support.patch, which is included in RHEL5 =

> kernels. Are these patches related, somehow? The RHEL5 patch causes =

> problems, as described at =

> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D241348. =


They are related in that they modify similar areas in the NFS code.
However, this patch only modifies the NFS code and not the rest of
the file systems and areas in the kernel.

My opinion on the referenced bugzilla is that things change and
it may be time to update applications and such to work in the
new world.  Applications which do not get modified, tend to work
less and less as time goes by because while the world changes
around them, they don't.

I don't believe that this is the only cause which will keep those
applications from working completely.  With the addition of the
LFS thing, they will start to encounter more and more things that
they are not prepared to deal with.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
