Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.vodafone.ie ([213.233.128.44]:13544 "EHLO
	mail2.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934588AbbIVUaO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2015 16:30:14 -0400
Subject: Re: [PATCH v2 10/9] copy_file_range.2: New page documenting
 copy_file_range()
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-11-git-send-email-Anna.Schumaker@Netapp.com>
 <55F52ABA.9070908@gmail.com> <20150914183223.GA28469@birch.djwong.org>
 <5601B5C7.7030704@Netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com, andros@netapp.com,
        hch@infradead.org
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <5601BA4B.9060709@draigBrady.com>
Date: Tue, 22 Sep 2015 21:30:03 +0100
MIME-Version: 1.0
In-Reply-To: <5601B5C7.7030704@Netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22/09/15 21:10, Anna Schumaker wrote:
> On 09/14/2015 02:32 PM, Darrick J. Wong wrote:
>> On Sun, Sep 13, 2015 at 09:50:18AM +0200, Michael Kerrisk (man-pages) wrote:
>>> Hi Anna,

>>> Furthermore, I even wonder if explicitly specifying flags as
>>> COPY_FR_COPY | COPY_FR_REFLINK should just generate an EINVAL
>>> error. 0 already gives us the behavior described above,
>>> and allowing the combination COPY_FR_COPY | COPY_FR_REFLINK
>>> perhaps just contributes to misleading the user that these
>>> flags are orthogonal, when in reality they are not. What do
>>> you think?
>>
>> Personally, I think it's a little weird that one turns on reflink with a flag;
>> turns on regular copy with a different flag; and turns on both by not
>> specifying either flag. :)
> 
> Is there a better behavior for flags=0?  I was thinking this would be what people want when they don't care how the copy happens in the kernel.

As a user, I'm fine with this default and the interface in general.

thanks,
Pádraig.
