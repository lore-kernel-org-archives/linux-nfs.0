Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4576 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097Ab2H1UFy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 16:05:54 -0400
Message-ID: <503D248F.5040900@netapp.com>
Date: Tue, 28 Aug 2012 16:05:35 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Frank Nicholas <frank@nicholasfamilycentral.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: kernel BUG at fs/nfs/idmap.c:684!
References: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com>  <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com>  <503CD925.7050000@netapp.com>  <F5B43205-C11E-4ED7-A530-DCE49B911BE6@nicholasfamilycentral.com>  <20120828174314.GA2202@umich.edu>  <CDF28CCA-4DFC-4CF7-880A-49E795E3389E@nicholasfamilycentral.com>  <C9C62063-74C8-4B58-98B1-E2ED28FC63D1@nicholasfamilycentral.com> <4FA345DA4F4AE44899BD2B03EEEC2FA908F755A3@SACEXCMBX04-PRD.hq.netapp.com> <503D090E.3060505@netapp.com> <513C6429-D5C4-453A-B4E9-CDE9B983C63A@nicholasfamilycentral.com> <B3C42AF5-88C8-4AF7-9B2C-C0510A73BDB1@nicholasfamilycentral.com>
In-Reply-To: <B3C42AF5-88C8-4AF7-9B2C-C0510A73BDB1@nicholasfamilycentral.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/28/2012 03:55 PM, Frank Nicholas wrote:
> On Aug 28, 2012, at 2:47 PM, Frank Nicholas <frank@nicholasfamilycentral.com> wrote:
> 
>> On Aug 28, 2012, at 2:08 PM, Bryan Schumaker <bjschuma@netapp.com> wrote:
>>
>>> On 08/28/2012 02:06 PM, Myklebust, Trond wrote:
>>>> On Tue, 2012-08-28 at 14:01 -0400, Frank Nicholas wrote:
>>>>
>>>> An early version of those patches did indeed cause problems such as the
>>>> above. Are you sure that you applied the patches that actually went
>>>> upstream in
>>>
>>> No, I don't think he did.  I forgot you fixed up a few things, so I sent him the last copy I had.
>>>
>>> - Bryan
>>>
>>>>
>>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=c5066945b7ea346a11424dbeb7830b7d7d00c206
>>>> and
>>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=12dfd080556124088ed61a292184947711b46cbe
>>>>
>>>
>>
>>
>> rpc.idmapd is running.
>>
>> I applied the patches Bryan e-mailed me.  I'll apply the linked patches & confirm they clear up the log entries.
>>
>> Thanks.
> 
> Linked patches have been applied.  syslog messages are gone and all seems to be good.  
> 
> What version of the kernel will include these patches?

I think 3.5.4, Greg K-H sent out email yesterday saying that they had just been added to the stable tree.

- Bryan

> 
> Thanks everyone for the quick replies & solution!
> 

