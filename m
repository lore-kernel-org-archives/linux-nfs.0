Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:37802 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753172Ab3AXEDA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 23:03:00 -0500
Message-ID: <5100B0EA.4050506@davequigley.com>
Date: Wed, 23 Jan 2013 22:56:26 -0500
From: Dave Quigley <selinux@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Steve Dickson <steved@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Stephen Smalley <sds@tycho.nsa.gov>, jmorris@namei.org,
        eparis@redhat.com
Subject: Re: [PATCH 01/14] Security: Add hook to calculate context based on
 a negative dentry.
References: <1358862042-27520-1-git-send-email-steved@redhat.com>  <1358862042-27520-2-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA91833244F@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91833244F@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/2013 1:31 PM, Myklebust, Trond wrote:
> On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> There is a time where we need to calculate a context without the
>> inode having been created yet. To do this we take the negative dentry and
>> calculate a context based on the process and the parent directory contexts.
>>
>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>   include/linux/security.h | 27 +++++++++++++++++++++++++++
>>   security/capability.c    |  8 ++++++++
>>   security/security.c      | 10 ++++++++++
>>   security/selinux/hooks.c | 35 +++++++++++++++++++++++++++++++++++
>>   4 files changed, 80 insertions(+)
>
> Linus won't accept a patch that changes the security code from Bruce or
> myself without acks from the security maintainers. I assume that means
> we need to get at least an ack from James Morris, and then possibly
> Stephen and Eric too...
>
>

Adding James Morris, Steve Smalley, and Eric Paris for an ACK. These 
patches have been reviewed on the security list many times in the past 
and we're just now trying to get them mainlined again. All past comments 
were addressed in them.
