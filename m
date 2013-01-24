Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:37824 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752923Ab3AXEE0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 23:04:26 -0500
Message-ID: <5100B140.6020505@davequigley.com>
Date: Wed, 23 Jan 2013 22:57:52 -0500
From: Dave Quigley <selinux@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Steve Dickson <steved@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Stephen Smalley <sds@tycho.nsa.gov>, eparis@redhat.com,
        jmorris@namei.org
Subject: Re: [PATCH 04/14] SELinux: Add new labeling type native labels
References: <1358862042-27520-1-git-send-email-steved@redhat.com>  <1358862042-27520-5-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9183324B1@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9183324B1@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/2013 1:36 PM, Myklebust, Trond wrote:
> On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> There currently doesn't exist a labeling type that is adequate for use with
>> labeled NFS. Since NFS doesn't really support xattrs we can't use the use xattr
>> labeling behavior. For this we developed a new labeling type. The native
>> labeling type is used solely by NFS to ensure NFS inodes are labeled at runtime
>> by the NFS code instead of relying on the SELinux security server on the client
>> end.
>>
>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>   include/linux/security.h            |  3 +++
>>   security/selinux/hooks.c            | 35 ++++++++++++++++++++++++++---------
>>   security/selinux/include/security.h |  2 ++
>>   security/selinux/ss/policydb.c      |  5 ++++-
>>   4 files changed, 35 insertions(+), 10 deletions(-)
>
> ...OK. You get the drift... :-)
>

Adding James Morris, Steve Smalley, and Eric Paris for an ACK. These 
patches have been reviewed on the security list many times in the past 
and we're just now trying to get them mainlined again. All past comments 
were addressed in them.


