Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:38016 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbaDLJ1I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Apr 2014 05:27:08 -0400
Message-ID: <534906D4.1030102@panasas.com>
Date: Sat, 12 Apr 2014 12:26:44 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
CC: Daniel Gryniewicz <dang@linuxbox.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Santosh Pathak <santoshp@panasas.com>,
        Benny Halevy <bhalevy@primarydata.com>,
        open-osd <osd-dev@open-osd.org>,
        Elizabeth Ellenbogen Ziph <elizabeth@linuxbox.com>,
        Sachin bhamare <sachin.bhamare@gmail.com>
Subject: Re: [osd-dev] [PATCH 1/3] ore: (trivial) reformat some code
References: <53467667.3010304@panasas.com> <53467757.40909@panasas.com> <148968805.223876.1397214732949.JavaMail.zimbra@desy.de> <53490246.2070000@panasas.com>
In-Reply-To: <53490246.2070000@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/12/2014 12:07 PM, Boaz Harrosh wrote:
>>> -			ret = _ore_add_parity_unit(ios, si, per_dev, cur_len);
>>> +			/* In writes cur_len just means if it's the
>>> +			 * last one. See _ore_add_parity_unit.
>>> +			 */
>>> +			ret = _ore_add_parity_unit(ios, si, per_dev,
>>> +						   ios->sp2d : length : cur_len);
>>
>> Hi Boaz, 
>>
>> did you meant
>>  
>>      ios->sp2d ? length : cur_len);
> 
> my god yes!! why doe it compile? 
> 
> Thanks man
> Boaz
> 

OK Now I know. This same line changes again in the last patch and there
it is correct. I have only always tested the 3 together so it never showed
up. I'll fix it for the next round

Thanks for the catch, you saved me. Beers on me next time
Boaz


