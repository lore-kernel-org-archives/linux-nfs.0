Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:37835 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753197Ab3AXEFQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 23:05:16 -0500
Message-ID: <5100B172.5040204@davequigley.com>
Date: Wed, 23 Jan 2013 22:58:42 -0500
From: Dave Quigley <selinux@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Steve Dickson <steved@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/14] KConfig: Add KConfig entries for Labeled NFS
References: <1358862042-27520-1-git-send-email-steved@redhat.com>  <1358862042-27520-6-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9183324C0@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9183324C0@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/2013 1:37 PM, Myklebust, Trond wrote:
> On Tue, 2013-01-22 at 08:40 -0500, Steve Dickson wrote:
>> From: David Quigley <dpquigl@davequigley.com>
>>
>> This patch adds two entries into the fs/KConfig file. The first entry
>> NFS_V4_SECURITY_LABEL enables security label support for the NFSv4 client while
>> the second entry NFSD_V4_SECURITY_LABEL enables security labeling support on
>> the server side.
>>
>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>> ---
>>   fs/nfs/Kconfig  | 16 ++++++++++++++++
>>   fs/nfsd/Kconfig | 13 +++++++++++++
>>   2 files changed, 29 insertions(+)
>
> Please split this into 2 patches. They should probably be the 2 last
> patches in the series.
>
>

Added on to the list of things to do and we'll get it taken care of.

Dave
