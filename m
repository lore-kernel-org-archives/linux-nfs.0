Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60339 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755276Ab3EHQnz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 May 2013 12:43:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "Linux FS devel list" <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/17] NFS: Client implementation of Labeled-NFS
Date: Wed, 8 May 2013 16:43:53 +0000
Message-ID: <1368031432.5978.3.camel@leira.trondhjem.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
	  <1367240239-19326-14-git-send-email-SteveD@redhat.com>
	 <1367435005.4189.36.camel@leira.trondhjem.org>
	 <518A7FA6.4090703@RedHat.com>
In-Reply-To: <518A7FA6.4090703@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-05-08 at 12:39 -0400, Steve Dickson wrote:
> 
> On 01/05/13 15:03, Myklebust, Trond wrote:
> >> @@ -2409,10 +2468,26 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
> >> >  			server->caps |= NFS_CAP_CTIME;
> >> >  		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_MODIFY)
> >> >  			server->caps |= NFS_CAP_MTIME;
> >> > +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> >> > +		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
> >> > +			server->caps |= NFS_CAP_SECURITY_LABEL;
> >> > +#endif
> >> > +		memcpy(server->attr_bitmask_nl, res.attr_bitmask, 
> >> > +				sizeof(server->attr_bitmask));
> >> > +
> >> > +		if (server->caps & NFS_CAP_SECURITY_LABEL)
> >> > +			server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
> >> >  
> >> >  		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
> >> >  		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
> >> > -		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
> >> > +		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA |
> >> > +							FATTR4_WORD1_TIME_MODIFY;
> >> > +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> >> > +		server->cache_consistency_bitmask[2] &= FATTR4_WORD2_SECURITY_LABEL;
> > Why? How is the security label relevant to cache consistency?
> Its used to the set label bit in the GETATTR that goes out with ACCESS compound.

The GETATTR that goes out with ACCESS is only there in order to get the
change attribute so that we know when to invalidate the access cache. It
is _only_ for cache consistency.

Why do we need to fetch the label too?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
