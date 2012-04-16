Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:47449 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787Ab2DPOie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 10:38:34 -0400
Message-ID: <4F8C2B6A.1000203@itwm.fraunhofer.de>
Date: Mon, 16 Apr 2012 16:23:38 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, Malahal Naineni <malahal@us.ibm.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, pstaubach@exagrid.com, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr
 call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com> <20120413150518.GA1987@us.ibm.com> <20120413114236.0e557e01@tlielax.poochiereds.net> <4F8B1B7B.3040304@itwm.fraunhofer.de> <20120415192714.GA3842@fieldses.org>
In-Reply-To: <20120415192714.GA3842@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/15/2012 09:27 PM, J. Bruce Fields wrote:
> On Sun, Apr 15, 2012 at 09:03:23PM +0200, Bernd Schubert wrote:
>> On 04/13/2012 05:42 PM, Jeff Layton wrote:
>>> (note: please don't trim the CC list!)
>>>
>>> Indefinitely does make some sense (as Peter articulated in his original
>>> set). It's possible you could race several times in a row, or a server
>>> misconfiguration or something has happened and you have a transient
>>> error that will eventually recover. His assertion was that any limit on
>>> the number of retries is by definition wrong. For NFS, a fatal signal
>>> ought to interrupt things as well, so retrying indefinitely has some
>>> appeal there.
>>>
>>> OTOH, we do have to contend with filesystems that might return ESTALE
>>> persistently for other reasons and that might not respond to signals.
>>> Miklos pointed out that some FUSE fs' do this in his review of Peter's
>>> set.
>>>
>>> As a purely defensive coding measure, limiting the number of retries to
>>> something finite makes sense. If we're going to do that though, I'd
>>> probably recommend that we set the number of retries be something
>>> higher just so that this is more resilient in the face of multiple
>>> races. Those other fs' might "spin" a bit in that case but it is an
>>> error condition and IMO resiliency trumps performance -- at least in
>>   this case.
>>
>> I am definitely voting against an infinite number of retries. I'm
>> working on FhGFS, which supports distributed meta data servers. So when
>> a file is moved around between directories, its file handle, which
>> contains the meta-data target id might become invalid.  As NFSv3 is
>> stateless we cannot inform the client about that and must return ESTALE
>> then.
>
> Note we're not talking about retrying the operation that returned ESTALE
> with the same filehandle--probably any server would return ESTALE again
> in that case.
>
> We're talking about re-looking up the path (in the case where we're
> implementing a system call that takes a path as an argument), and then
> retrying the operation with the newly looked-up filehandle.
>

Oh, sorry my mistake. Somehow I missed that it is really _only_ about 
path lookups and not already opened files.

Thanks,
Bernd
