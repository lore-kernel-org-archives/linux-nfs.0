Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp109.prem.mail.sp1.yahoo.com ([98.136.44.54]:30124 "HELO
	smtp109.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751524Ab1EDRtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 13:49:19 -0400
Message-ID: <4DC1900D.3010804@schaufler-ca.com>
Date: Wed, 04 May 2011 10:42:37 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
To: Roberto Sassu <roberto.sassu@polito.it>
CC: Tyler Hicks <tyhicks@linux.vnet.ibm.com>,
        linux-security-module@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com, jmorris@namei.org,
        zohar@linux.vnet.ibm.com, safford@watson.ibm.com,
        kirkland@canonical.com, ecryptfs-devel@lists.launchpad.net,
        eparis@redhat.com, sds@tycho.nsa.gov, selinux@tycho.nsa.gov,
        viro@zeniv.linux.org.uk, john.johansen@canonical.com,
        apparmor@lists.ubuntu.com, bfields@fieldses.org, neilb@suse.de,
        linux-nfs@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC][PATCH 0/7] File descriptor labeling
References: <201104291139.37489.roberto.sassu@polito.it> <201105021053.54031.roberto.sassu@polito.it> <4DC088A8.4000300@schaufler-ca.com> <201105041119.57493.roberto.sassu@polito.it>
In-Reply-To: <201105041119.57493.roberto.sassu@polito.it>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 5/4/2011 2:19 AM, Roberto Sassu wrote:
> On Wednesday, May 04, 2011 12:58:48 AM Casey Schaufler wrote:
>> On 5/2/2011 1:53 AM, Roberto Sassu wrote:
>> ...
>>>> Right, but what I don't understand is why you can't use existing
>>>> mechanisms to achieve this? NFS manages (mostly).
>>> Please, can you explain better this thought?
>> NFS provides a network "view" of an ext4 (or any type for that matter)
>> filesystem. NFS does not support extended attributes, but there has been
>> ongoing work on that. It seems that if NFS does not require the kind
>> of changes you are requesting you shouldn't either.
> I'm not familiar with NFS, so i cannot answer about this scenario.

NFS provides the historical and prototypical example of a layered
filesystem. If you are implementing a layered filesystem and have
not researched NFS you are missing out on the bulk of the experience
and wisdom on the subject.

> I'm adding in CC also the NFS mantainers and the mailing list so
> that they can express their point of view. The whole thread is
> available at:
>
> https://lkml.org/lkml/2011/4/27/201
>
> Roberto Sassu

