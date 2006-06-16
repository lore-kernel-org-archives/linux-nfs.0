From: Amit Gud <agud@redhat.com>
Subject: Re: [PATCH 0 / 1] Move NFS mount code from util-linux to
 nfs-utils - take2
Date: Thu, 15 Jun 2006 23:45:24 -0400
Message-ID: <44922954.7070101@redhat.com>
References: <448DF279.8090005@redhat.com>
	<17554.9694.465446.422126@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fr5Dr-0000SA-OE
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:42:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fr5Dp-00085i-JZ
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:42:16 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17554.9694.465446.422126@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Neil Brown wrote:
> On Monday June 12, agud@redhat.com wrote:
>>
>> AG
>> -- 
>> May the source be with you.
>> http://www.cis.ksu.edu/~gud
>>
>> Moves the NFS mount code out of util-linux to nfs-utils. The primary reason being ease of maintainability, and keeping util-linux away from all the filesystem-specifc worries.
>>
>> Adds a new directory 'mount' under utils. Creates a binary mount.nfs. Three symbolic links are created to this binary - mount.nfs4, umount.nfs and umount.nfs4. It is simpler and avoids code duplication (or overhead of fork->exec) by keeping umount code in a single binary along with the mount code. Mount code uses umount to handle certain fail cases. It also makes sense to keep single binary for all the versions of the NFS, as opposed to having seperate binaries mount.nfs and mount.nfs4, since the code falls back to lower version if mounting with v4 fails. Adds two man pages - mount.nfs(8) and umount.nfs(8).
>>
>> Patches are split into two parts:
>> [1/2] nfsmount-migration-to-nfsutils-v2.patch
>> [2/2] nfsmount-migration-to-nfsutils-support-v2.patch
>>
>> After applying the patches before configuring and compiling, do:
>> $ rpcgen -c utils/mount/nfsmount.x > utils/mount/nfsmount_xdr.c
>> $ rpcgen -h utils/mount/nfsmount.x > utils/mount/nfsmount.h
>> $ sh autogen.sh
> 
> The 'rpcgen' should be done by the Makefile.  I have added a patch
> which does this.
> However there are now two slightly different nfsmount.x files in the
> tree
> 
>    ./support/export/mount.x
>    ./utils/mount/nfsmount.x
> 
> If they could be unified (leave the one in support/export, but merge
> in any changes you want from nfsmount.x) and then use the libexport.a
> library to get the nfsmount_clnt.o etc, that would be really good.

sounds good.

> You can see the current code at
>   git://linux-nfs.org/nfs-utils
> 
> Further patches against that would be great.
> 
> Also, it seems really odd that you need
>    ./configure --without-mount
> it you want it to compile the mount client.
> Surely it should be --with-mount!!!
> What is the reasoning there?

I went with the GNU Autoconf Manual ;), 
http://www.gnu.org/software/autoconf/manual/autoconf-2.57/html_mono/autoconf.html#SEC130, 
which says --with-foo, when external program foo is to be used, and 
--without-foo otherwise. But I know, it sounds rather odd. I think, I'II 
change it to --with-mount.


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
