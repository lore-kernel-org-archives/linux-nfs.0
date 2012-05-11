Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-04.shaw.ca ([64.59.134.12]:51978 "EHLO
	smtp-out-04.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab2EKJD4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 05:03:56 -0400
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20120510171016.B45BA2C096@topped-with-meat.com>
Date: Fri, 11 May 2012 02:54:13 -0600
Cc: David Howells <dhowells@redhat.com>, Dave Chinner <david@fromorbit.com>,
        "bfields@fieldses.org Fields" <bfields@fieldses.org>,
        "smfrench@gmail.com French" <smfrench@gmail.com>,
        "ben@decadent.org.uk Hutchings" <ben@decadent.org.uk>,
        "Trond.Myklebust@netapp.com Myklebust" <Trond.Myklebust@netapp.com>,
        "linux-fsdevel@vger.kernel.org Devel" <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org,
        "linux-ext4@vger.kernel.org List" <linux-ext4@vger.kernel.org>,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Message-Id: <258C4ED4-2FB3-4E3F-A99E-842D231BA869@dilger.ca>
References: <73759631-F1E4-4352-9FE6-E9F576F793FB@gmail.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <16281.1336508382@redhat.com> <20120509002420.GL5091@dastard> <14477.1336641794@redhat.com> <20120510171016.B45BA2C096@topped-with-meat.com>
To: Roland McGrath <roland@hack.frob.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-10, at 11:10 AM, Roland McGrath wrote:
> POSIX specifies st_blksize thusly: "A file system-specific preferred
> I/O block size for this object. In some file system types, this may
> vary from file to file."
> 
> Since there is only one available to POSIX applications, it should map
> to the one that's described as "preferred IO size for general usage".

Sure, but statxat() isn't a POSIX API.

While I agree with the idea that there should be enough information about the underlying layout for applications to be able to submit good IO, it doesn't help if we have a bunch of extra fields that have vague meanings. 

They will get filled in by the filesystem in a haphazard way, and will not be used by application developers that don't understand what they mean.

Cheers, Andreas





