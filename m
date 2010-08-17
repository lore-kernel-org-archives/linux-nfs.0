Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:57919 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab0HQVrS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 17:47:18 -0400
Subject: Re: [PATCH 1/2] Teach clients to map numeric strings into valid
 uids and gids.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <4C6B00B1.4060206@RedHat.com>
References: <1282073925-18707-1-git-send-email-steved@redhat.com>
	 <1282073925-18707-2-git-send-email-steved@redhat.com>
	 <1282076855.12506.2.camel@heimdal.trondhjem.org>
	 <4C6B00B1.4060206@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Aug 2010 17:47:13 -0400
Message-ID: <1282081633.18385.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-17 at 17:35 -0400, Steve Dickson wrote:
> 
> On 08/17/2010 04:27 PM, Trond Myklebust wrote:
> > On Tue, 2010-08-17 at 15:38 -0400, Steve Dickson wrote:
> >> When a server can not map a uid or gid they can send
> >> an numeric string (one that does not include the @domain)
> >> of the given id. When this occurs the client will can use
> >> that numeric representation iff that id exists on the client.
> >>
> >> Signed-off-by: Steve Dickson <steved@redhat.com>
> >> ---
> >>  utils/idmapd/idmapd.c |   38 ++++++++++++++++++++++++++++++++++++++
> >>  1 files changed, 38 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> >> index 9ecab66..d6799c9 100644
> >> --- a/utils/idmapd/idmapd.c
> >> +++ b/utils/idmapd/idmapd.c
> >> @@ -826,6 +826,21 @@ idtonameres(struct idmap_msg *im)
> >>  		im->im_status = IDMAP_STATUS_SUCCESS;
> >>  }
> >>  
> >> +static int
> >> +alldigits(char *name)
> >> +{
> >> +	char *p = name;
> >> +
> >> +	if (name == NULL)
> >> +		return 0;
> >> +
> >> +	while (*p != '\0') {
> >> +		if (!isdigit(*p++))
> >> +			return 0;
> >> +	}
> >> +	return 1;
> >> +}
> >> +
> >>  static void
> >>  nametoidres(struct idmap_msg *im)
> >>  {
> >> @@ -843,6 +858,18 @@ nametoidres(struct idmap_msg *im)
> >>  		ret = nfs4_name_to_uid(im->im_name, &uid);
> >>  		im->im_id = (u_int32_t) uid;
> >>  		if (ret) {
> >> +			/*
> >> +			 * When a server sends numeric string that's
> >> +			 * lacking the @domain part, and the uid exists
> >> +			 * use the numeric string as the uid. 
> >> +			 */
> >> +			if (alldigits(im->im_name)) {
> >> +				sscanf(im->im_name, "%u", &uid);
> >> +				if (getpwuid(uid) != NULL) {
> >> +					im->im_id = uid;	
> >> +					break;
> >> +				}
> >> +			}
> >>  			im->im_status = IDMAP_STATUS_LOOKUPFAIL;
> >>  			im->im_id = nobodyuid;
> >>  		}
> >> @@ -851,6 +878,17 @@ nametoidres(struct idmap_msg *im)
> >>  		ret = nfs4_name_to_gid(im->im_name, &gid);
> >>  		im->im_id = (u_int32_t) gid;
> >>  		if (ret) {
> >> +			/*
> >> +			 * Do the same type of mapping of a numeric string
> >> +			 * sent as the gid.
> >> +			 */
> >> +			if (alldigits(im->im_name)) {
> >> +				sscanf(im->im_name, "%u", &gid);
> >> +				if (getgrgid(gid) != NULL) {
> >> +					im->im_id = gid;
> >> +					break;
> >> +				}
> >> +			}
> >>  			im->im_status = IDMAP_STATUS_LOOKUPFAIL;
> >>  			im->im_id = nobodygid;
> >>  		}
> > 
> > Wouldn't it make more sense to put this into libnfsidmap instead?
> I did think of that but since the nobody ids are being set here I 
> figured I made the most sense to do here... plus this is pretty 
> simple code why hide a way in the library and make it more 
> difficult to debug... 

It means that Bryan is going to have to duplicate it all in the new
highly scalable idmapper.

Ditto for the nobody ids.

What's the point of having the library when it doesn't do the full NFSv4
idmapping for you?

Cheers
  Trond

