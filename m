Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14356 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755726Ab3KNTR4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Nov 2013 14:17:56 -0500
Message-ID: <528521DF.5040201@netapp.com>
Date: Thu, 14 Nov 2013 14:17:51 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Cedric Blancher <cedric.blancher@gmail.com>
CC: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/3] NFSD: Implement SEEK
References: <1384371057-16454-1-git-send-email-bjschuma@netapp.com> <CALXu0UfQuj+BNntibGf3CXcBnbP0pHTnZ5-Rp6FAwhfeNxjoow@mail.gmail.com>
In-Reply-To: <CALXu0UfQuj+BNntibGf3CXcBnbP0pHTnZ5-Rp6FAwhfeNxjoow@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/14/2013 11:47 AM, Cedric Blancher wrote:
> On 13 November 2013 20:30, Anna Schumaker <bjschuma@netapp.com> wrote:
>> These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS is
>> still under discussion with the IETF after my last series of patches, so I
>> am holding off on resubmitting until after spec discussion dies down.
>>
>> Questions?  Comments?  Thoughts?
>> Anna
> 
> 1. Doesn't SEEK_HOLE/SEEK_DATA already work in NFSv4? I always had the
> impression this worked there...

If we did, it was vfs-level seeking.  HOLE and DATA support are new to NFS with v4.2.

> 
> 2. Does http://svn.nrubsig.org/svn/people/gisburn/code/sparsefiles/lsholes.c
> work with your changes (the name is unfortunate, but its useful to
> list the holes in a file and even has a short test)?

lsholes.c passes on NFS with these changes, although I think it needs a "-h" option to tell me how to use it without looking at the code :)

> 
> 3. If you implement SEEK_HOLE/SEEK_DATA support you have to alter
> fpathconf() support and implement the _PC_MIN_HOLE_SIZE properly.

I don't think the NFS server exports a "minimum hole size" attribute, so I don't know how to find this without spec changes.

Anna

> 
> Ced
> 

