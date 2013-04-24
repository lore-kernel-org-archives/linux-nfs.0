Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758459Ab3DXWPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 18:15:08 -0400
Message-ID: <51785962.7080008@RedHat.com>
Date: Wed, 24 Apr 2013 18:14:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 16/17] NFSD: Server implementation of MAC Labeling
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com> <1366834683-29075-17-git-send-email-SteveD@redhat.com> <20130424212827.GK20275@fieldses.org>
In-Reply-To: <20130424212827.GK20275@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24/04/13 17:28, J. Bruce Fields wrote:
>> @@ -3231,11 +3340,13 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>> >  		WRITE32(2);
>> >  		WRITE32(0);
>> >  		WRITE32(0);
>> > +		WRITE32(0);
> Note that "2" above is the length of the bitmap field that follows.
> 
>> >  	}
>> >  	else {
>> >  		WRITE32(2);
>> >  		WRITE32(setattr->sa_bmval[0]);
>> >  		WRITE32(setattr->sa_bmval[1]);
>> > +		WRITE32(setattr->sa_bmval[2]);
> Ditto.
Right... I did miss that....

steved.
