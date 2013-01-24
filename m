Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:37804 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752868Ab3AXEDm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 23:03:42 -0500
Message-ID: <5100B114.8020909@davequigley.com>
Date: Wed, 23 Jan 2013 22:57:08 -0500
From: Dave Quigley <selinux@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Steve Dickson <steved@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Stephen Smalley <sds@tycho.nsa.gov>, jmorris@namei.org,
        eparis@redhat.com
Subject: Re: [PATCH 02/14] Security: Add Hook to test if the particular xattr
 is part of a MAC model.
References: <1358862042-27520-1-git-send-email-steved@redhat.com>  <1358862042-27520-3-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA918332485@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA918332485@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/2013 1:32 PM, Myklebust, Trond wrote:
> On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> The interface to request security labels from user space is the xattr
>> interface. When requesting the security label from an NFS server it is
>> important to make sure the requested xattr actually is a MAC label. This allows
>> us to make sure that we get the desired semantics from the attribute instead of
>> something else such as capabilities or a time based LSM.
>>
>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>   include/linux/security.h   | 14 ++++++++++++++
>>   security/capability.c      |  6 ++++++
>>   security/security.c        |  6 ++++++
>>   security/selinux/hooks.c   |  6 ++++++
>>   security/smack/smack_lsm.c | 11 +++++++++++
>>   5 files changed, 43 insertions(+)
>>
> Ditto here. We'll need Acks from James, Stephen, Eric and Casey.
>

Adding James Morris, Steve Smalley, and Eric Paris for an ACK. These 
patches have been reviewed on the security list many times in the past 
and we're just now trying to get them mainlined again. All past comments 
were addressed in them.


