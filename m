Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161383Ab2COUp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 16:45:59 -0400
Message-ID: <4F6254FA.5000209@RedHat.com>
Date: Thu, 15 Mar 2012 16:45:46 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Peter Staubach <pstaubach@exagrid.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] nfsd: Warn when no servers are specified on the command
 line
References: <1331832223-20737-1-git-send-email-steved@redhat.com> <FA8A9A935BFD3A4D8F0CDA1C4F611BCC062D5C800D@IT-1874.Isys.com> <4F6232CF.7010509@RedHat.com> <20120315184005.GB9848@fieldses.org>
In-Reply-To: <20120315184005.GB9848@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/15/2012 02:40 PM, J. Bruce Fields wrote:
> On Thu, Mar 15, 2012 at 02:19:59PM -0400, Steve Dickson wrote:
>>
>>
>> On 03/15/2012 02:01 PM, Peter Staubach wrote:
>>> I am curious why such a message is required?  
>> To let people know their NFS server may not be configured as expected.
>>
>>> Isn't the reason for having a default is so that the option does not need to specified?
>> I guess... but starting one nfsd is probably not what people
> 
> That's strange--when did the default get changed to 1?
> 
> Let's please just fix the default and not warn about something that's
> not really a bug....
Will do... I'll just change the default from 1 to 8.

BTW, the context for all this is
   https://bugzilla.redhat.com/show_bug.cgi?id=757452

steved.

> 
> --b.
> 
>> want to do... Maybe bumping the default up to a more reasonable 
>> number could work... 
>>
>> steved.
>>
>>>
>>> 	Thanx...
>>>
>>> 		ps
>>>
>>>
>>> -----Original Message-----
>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Steve Dickson
>>> Sent: Thursday, March 15, 2012 1:24 PM
>>> To: Linux NFS Mailing list
>>> Subject: [PATCH 1/1] nfsd: Warn when no servers are specified on the command line
>>>
>>> When the number of servers are not specified on the command, log a warning message that the default number of services will be started
>>>
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>>  utils/nfsd/nfsd.c |    7 +++++--
>>>  1 files changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c index 8bc5d3a..c744ee1 100644
>>> --- a/utils/nfsd/nfsd.c
>>> +++ b/utils/nfsd/nfsd.c
>>> @@ -188,6 +188,8 @@ main(int argc, char **argv)
>>>  		}
>>>  	}
>>>  
>>> +	xlog_open(progname);
>>> +
>>>  	if (optind < argc) {
>>>  		if ((count = atoi(argv[optind])) < 0) {
>>>  			/* insane # of servers */
>>> @@ -203,10 +205,11 @@ main(int argc, char **argv)
>>>  			socket_up = 1;
>>>  			goto set_threads;
>>>  		}
>>> +	} else {
>>> +		xlog(L_WARNING, "No server number specified. '%d' nfsd will be started",
>>> +			count);
>>>  	}
>>>  
>>> -	xlog_open(progname);
>>> -
>>>  	nfsd_enable_protos(&proto4, &proto6);
>>>  
>>>  	if (!NFSCTL_TCPISSET(protobits)) {
>>> --
>>> 1.7.7.6
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
