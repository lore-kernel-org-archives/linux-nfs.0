Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:56923 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753369Ab2KLUoZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:44:25 -0500
Message-ID: <50A15FAB.9040208@davequigley.com>
Date: Mon, 12 Nov 2012 15:44:27 -0500
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: trond.myklebust@netapp.com, sds@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <20121112163314.GM30713@fieldses.org>
In-Reply-To: <20121112163314.GM30713@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2012 11:33 AM, J. Bruce Fields wrote:
> On Mon, Nov 12, 2012 at 01:15:34AM -0500, David Quigley wrote:
>> The NFSv4 working group has finally accepted Labeled NFS as part of the NFSv4.2
>> specification and it has been decided that a reposting of the Labeled NFS code
>> for inclusion into mainline was a good idea. The patches have been rebased onto
>> v3.7-rc2 and have been tested against the SELinux testsuite with the only
>> failures being for features not supported by NFS.
>
> This will still need support for FATTR4_CHANGE_SEC_LABEL.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

That's true. At the time we didn't have FATTR4_CHANGE_SEC_LABEL so it 
wasn't implemented. This should be a good start at Labeled NFS support 
but will take more work.
