Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:36466 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062AbcCVCBk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 22:01:40 -0400
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: Making an interface for alternative data streams
From: Richard Yao <ryao@gentoo.org>
In-Reply-To: <20160321204041.GA807@fieldses.org>
Date: Mon, 21 Mar 2016 22:01:35 -0400
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Message-Id: <34E9F5BC-E8D4-405E-926E-DF2058E31B5F@gentoo.org>
References: <56F03945.40208@gentoo.org> <56F05745.50204@gentoo.org> <20160321204041.GA807@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 21, 2016, at 4:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Mon, Mar 21, 2016 at 04:19:17PM -0400, Richard Yao wrote:
>> Maybe I should clarify that the idea is to allow read/write/list of
>> extended attributes via read/write/readdir so that those that want
>> extended attributes that are alternative data streams can have them. I
>> do not want to see extended attributes and alternative data streams be
>> different things.
> 
> I think there are differences between the two that make this awkward.
> Does anyone actually use alternative data stream for anything that makes
> the effort worthwhile?

For particularly large extended attributes, avoiding having to read the entire value into userspace, modify it and write it back is nice. I believe that XFS goes up to 64KB.

I have had multiple user inquiries regarding this each year. They tend to fall into two camps. One is the Samba camp while the other wants saner fsync semantics. When your disk format uses tar files for extended attributes, doing fsync either omits them or iterates through the extended attribute directory. Neither is very nice. At the moment, the answer in the driver that I develop is it works as long as they are not too big and a non-cross platform compatible option is enabled to store small ones the IRIX way that most in-tree file drivers use. Maybe the right answer is to make it user configurable, although having an interface that lets users target a specific extended attribute would be nice.

I already have the idea of implementing it through an ioctl without any changes to the VFS. I imagine if I do that userland software will begin adopting it and then people will start pinging other filesystem driver developers requesting support, like what happened with reflinks (although the majority of people using them seem to be using them in internal things that never see the light of day). At that point, we could be stuck with a  significant body of userland software that expects an interface that probably is less agreeable than what it would have been had people sat down to discuss it in the first place.

>> Alternative data streams are in the NFSv4 specification, so I thought
>> that the developers of the NFS client driver would want something like
>> this.
> 
> Somebody would have to make a convincing argument that it's worthwhile.
> 
> Note there's also a proposal to add extended attributes to the NFSv4
> protocol:
> 
>    https://tools.ietf.org/html/draft-ietf-nfsv4-xattrs-02

I had not known about that. If that happens and we start seeing separate namespaces, we will need alternative data streams from the perspective of being able to archive the contents of a file system on one POSIX system and restore it on another. There is just no way that userland tools like rsync would be able to keep treating the two as equivalent when separate namespaces come into play and migrating to Linux would guarantee data loss when both are in use.

> That also has some more discussion of mismatches between the named- and
> extended- attribute interfaces:
> 
>    https://tools.ietf.org/html/draft-ietf-nfsv4-xattrs-02#section-5

That describes the exact problems with the current approach in the ZoL driver.

> 
> --b.
