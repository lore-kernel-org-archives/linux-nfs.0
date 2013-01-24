Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:37816 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752923Ab3AXEEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 23:04:07 -0500
Message-ID: <5100B12B.1090706@davequigley.com>
Date: Wed, 23 Jan 2013 22:57:31 -0500
From: Dave Quigley <selinux@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Steve Dickson <steved@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>, jmorris@namei.org,
        Stephen Smalley <sds@tycho.nsa.gov>, eparis@redhat.com
Subject: Re: [PATCH 03/14] LSM: Add flags field to security_sb_set_mnt_opts
 for in kernel mount data.
References: <1358862042-27520-1-git-send-email-steved@redhat.com>  <1358862042-27520-4-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9183324A2@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9183324A2@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/2013 1:35 PM, Myklebust, Trond wrote:
> On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> There is no way to differentiate if a text mount option is passed from user
>> space or the kernel. A flags field is being added to the
>> security_sb_set_mnt_opts hook to allow for in kernel security flags to be sent
>> to the LSM for processing in addition to the text options received from mount.
>> This patch also updated existing code to fix compilation errors.
>>
>> Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>   fs/nfs/super.c           |  3 ++-
>>   include/linux/security.h | 13 ++++++++++---
>>   security/capability.c    |  5 ++++-
>>   security/security.c      |  7 +++++--
>>   security/selinux/hooks.c | 12 ++++++++++--
>>   5 files changed, 31 insertions(+), 9 deletions(-)
>>
> Ditto. Need Acks from James, Stephen and Eric.
>

Adding James Morris, Steve Smalley, and Eric Paris for an ACK. These 
patches have been reviewed on the security list many times in the past 
and we're just now trying to get them mainlined again. All past comments 
were addressed in them.


