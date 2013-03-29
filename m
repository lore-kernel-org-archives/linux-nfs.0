Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:49465 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754409Ab3C2Dje (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2013 23:39:34 -0400
Message-ID: <51550B67.40108@davequigley.com>
Date: Thu, 28 Mar 2013 23:32:55 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com> <1364478845-29796-14-git-send-email-SteveD@redhat.com> <20130328185845.GI7080@fieldses.org> <20130328191918.GA14748@fieldses.org>
In-Reply-To: <20130328191918.GA14748@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/28/2013 3:19 PM, J. Bruce Fields wrote:
> Dave, I think these are both questions for you?
>
> --b.
>
> On Thu, Mar 28, 2013 at 02:58:45PM -0400, bfields wrote:
>> On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
>>> @@ -1988,6 +2044,50 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
>>>   			      FATTR4_WORD0_RDATTR_ERROR)
>>>   #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
>>>
>>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>>> +static inline __be32
>>> +nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
>>> +{
>>> +	void *context;
>>> +	int err;
>>> +	int len;
>>> +	uint32_t pi = 0;
>>> +	uint32_t lfs = 0;
>>> +	__be32 *p = *pp;
>>> +
>>> +	err = 0;
>>> +	(void)security_inode_getsecctx(dentry->d_inode, &context, &len);
>>> +	if (len < 0)
>>> +		return nfserrno(len);
>>> +
>>> +	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4)) {
>>> +		err = nfserr_resource;
>>> +		goto out;
>>> +	}
>>> +
>>> +	/* XXX: A call to the translation code should be placed here
>>> +	 * for now send 0  until we have that to indicate the null
>>> +	 * translation */
>>
>> Could we better a better comment here?

We could remove this comment all together if you want. We're trying to 
indicate that at some point in the future there will be a label 
translation facility like idmapd but for labels instead. This is where 
the call would go if we had it. I had a basic version of the code a long 
time ago and that is where I had the call but there was way too much 
work to make it usable for now. Instead I just pass the null translation 
indicator on the wire and we wave our hands and say don't look at the 
man behind the curtain.

> ...
>>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>>> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>> +		struct nfs4_label *label)
>>> +{
>>> +	__be32 error;
>>> +	int host_error;
>>> +	struct dentry *dentry;
>>> +
>>> +	/* XXX: should we have a MAY_SSECCTX? */
>>
>> Again: could we get an answer to this question?

I'm pretty sure we can just remove that comment. It was a question from 
about 5 years ago now and I never found a compelling reason to say yes 
to it.

>>
>> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

