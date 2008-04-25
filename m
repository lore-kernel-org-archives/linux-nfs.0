From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 16:37:56 -0400
Message-ID: <29105BE5-81BE-4C7C-9E4A-EB133200217E@oracle.com>
References: <20080425080535.GA4999@uio.no> <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com> <20080425163457.GA6952@uio.no> <F4C3F5C0-1D60-4285-9CB3-171C70C96B03@oracle.com> <20080425165921.GA7108@uio.no> <9CE7224B-002F-48B8-9DCB-8776A61167EF@oracle.com> <20080425173833.GA7306@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:24681 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764237AbYDYUir (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 16:38:47 -0400
In-Reply-To: <20080425173833.GA7306-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 25, 2008, at 1:38 PM, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 01:11:02PM -0400, Chuck Lever wrote:
>> Just change "*timeout +=" to "*timeout =" in parse_retry_option().
>>
>> That was the bug I was trying to fix in the first place.  Sigh.
>
> That fixes it -- thanks!

Thanks for testing.  I'll post a corrected patch to Mr. Dickson in a  
bit.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
