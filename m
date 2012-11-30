Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:54315 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754777Ab2K3ACb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 19:02:31 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Thu, 29 Nov 2012 19:02:28 -0500
From: David Quigley <dpquigl@davequigley.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: <bfields@fieldses.org>, <trond.myklebust@netapp.com>, <sds@tycho.nsa.gov>,
        <linux-nfs@vger.kernel.org>, <selinux@tycho.nsa.gov>,
        <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <0ff94ca24f0c686ac7035c6dd9292746@countercultured.net>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
 <50ABF1A5.2010406@schaufler-ca.com> <50AC1A74.7080105@davequigley.com>
 <50AC2117.801@schaufler-ca.com> <50AC224D.3080108@davequigley.com>
 <50AC41DC.5070607@schaufler-ca.com> <50AC4A7A.6010208@davequigley.com>
 <50B65E7E.4030607@schaufler-ca.com> <50B6B706.1010002@davequigley.com>
 <50B6C398.90002@schaufler-ca.com> <50B7E189.80200@schaufler-ca.com>
 <0ff94ca24f0c686ac7035c6dd9292746@countercultured.net>
Message-ID: <366126a9d2f81c76c116059d4e3202d1@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2012 17:49, David Quigley wrote:
> I have an idea of what it is then. I'm cloning the tree so I can take
> a look really quick but I have a feeling that I didn't convey
> something properly and it got messed up in the implementation. If
> that's the case I'll make sure to be clearer next time to avoid
> confusion.
>
> --
> This message was distributed to subscribers of the selinux mailing 
> list.
> If you no longer wish to subscribe, send mail to 
> majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.


So the problem isn't clear to me. If we look in fs/nfs/nfs4proc.c we'll 
see the xattr handlers for the security namespace. This will strip off 
the security and should pass the second part to the security_ismaclabel 
call on the key.

The code in question is below.


static int nfs4_xattr_get_nfs4_label(struct dentry *dentry, const char 
*key,
                                    void *buf, size_t buflen, int type)
{
         if (security_ismaclabel(key))
                 return nfs4_get_security_label(dentry->d_inode, buf, 
buflen);
         return -EOPNOTSUPP;
}

This means whatever is making the getxattr call from userspace is 
requesting security.selinux instead of security.smack. Is there a 
different command to ls that will give you security.smack (or whatever 
it is)? what happens if you install getfattr and do getfattr -n 
security.whatever -m security.* /mnt/file

