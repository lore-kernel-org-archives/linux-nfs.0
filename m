Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay1.sgi.com ([192.48.179.29]:50404 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363Ab2KIRxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Nov 2012 12:53:09 -0500
Message-ID: <509D42FC.8080204@sgi.com>
Date: Fri, 09 Nov 2012 11:53:00 -0600
From: Mark Tinguely <tinguely@sgi.com>
MIME-Version: 1.0
To: Florian Pritz <bluewind@xinu.at>
CC: Ben Myers <bpm@sgi.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, Alex Elder <elder@kernel.org>,
        xfs@oss.sgi.com
Subject: Re: NFS stalls when writing - linux 3.6.x
References: <50957087.6050008@xinu.at> <20121107190724.GD7421@fieldses.org> <509D2993.4050604@xinu.at> <20121109163658.GE6171@fieldses.org> <20121109172014.GT9783@sgi.com> <509D3C9A.6040209@xinu.at>
In-Reply-To: <509D3C9A.6040209@xinu.at>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/09/12 11:25, Florian Pritz wrote:
> On 09.11.2012 18:20, Ben Myers wrote:
>> I took a brief look but there were no slam dunks.  This seems like it might be
>> a candidate:
>>
>> 8375f922 - xfs: re-enable xfsaild idle mode and fix associated races
>>
>> The sysrq-trigger information would definately be helpful.  Meanwhile I'll see
>> if I can reproduce the issue.
>
> No idea why it doesn't show up on gmane yet (the excerpt is from my mail
> to the list), but I've uploaded it here[1]. The link will be valid for
> 10 days.
>
> [1]: https://paste.xinu.at/koXRw/
>
>
>
>
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs

Thank-you for the task list. Could we get a dump of the hang?

  # echo c >/proc/sysrq-trigger

It requires kdump configured.

--Mark.
