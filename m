Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37972 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbaEWOl3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 10:41:29 -0400
Date: Fri, 23 May 2014 10:41:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSD: Ignore and warn once for more fslocs or more
 uuids
Message-ID: <20140523144128.GO25423@fieldses.org>
References: <537F38AB.10102@gmail.com>
 <20140523135435.GK25423@fieldses.org>
 <537F5A1A.9000005@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537F5A1A.9000005@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 10:24:26PM +0800, Kinglong Mee wrote:
> On 5/23/2014 21:54, J. Bruce Fields wrote:
> > On Fri, May 23, 2014 at 08:01:47PM +0800, Kinglong Mee wrote:
> >> If mountd writes more fslocs or more uuids, just ignore and warn once.
> > 
> > So the current behavior is a leak?
> 
> Yes, there is a memory leak for more fslocs or more uuids.
> 
> > 
> > Have you observed any version of mountd actually writing more than one
> > of these?
> 
> Sorry, i don't checkout it.
> I just review the codes, and rewrit nfs-utils to writing more fslocs or uuids.
> 
> > 
> > If not, I'd prefer to return an error.
> 
> You mean return -EINVAL instead of ignoring it with return 0? 

Right.  If somebody introduces weird mountd behavior I'd rather they see
it fail right away.  And also I think it's a little easier to extend
these calls later if we error out on invalid input.

Also, remove the WARN_ON_ONCE.  We usually reserve BUG or WARN for cases
where we believe the kernel itself has a bug, and avoid them in cases
where they could be triggered by userland.  (Admittedly mountd is very
special userland, but still I'd rather it not be able to trigger these.)

--b.

> 
> Although, i miss checking the more "secinfo" in secinfo_parse() right now,
> for no memory leak. I will adds it after decides how to fix above.
> 
> thanks,
> Kinglong Mee
> 
> > 
> > --b.
> > 
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  fs/nfsd/export.c | 12 ++++++++++++
> >>  1 file changed, 12 insertions(+)
> >>
> >> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> >> index 90d37b6..1d56ae3 100644
> >> --- a/fs/nfsd/export.c
> >> +++ b/fs/nfsd/export.c
> >> @@ -394,6 +394,12 @@ fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
> >>  	int len;
> >>  	int migrated, i, err;
> >>  
> >> +	/* utils writes more fslocs than one */
> >> +	if (fsloc->locations) {
> >> +		WARN_ON_ONCE(1);
> >> +		return 0;
> >> +	}
> >> +
> >>  	/* listsize */
> >>  	err = get_uint(mesg, &fsloc->locations_count);
> >>  	if (err)
> >> @@ -485,6 +491,12 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
> >>  {
> >>  	int len;
> >>  
> >> +	/* utils writes more uuid than one */
> >> +	if (*puuid) {
> >> +		WARN_ON_ONCE(1);
> >> +		return 0;
> >> +	}
> >> +
> >>  	/* expect a 16 byte uuid encoded as \xXXXX... */
> >>  	len = qword_get(mesg, buf, PAGE_SIZE);
> >>  	if (len != EX_UUID_LEN)
> >> -- 
> >> 1.9.0
> >>
> > 
