From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount: silently fails when bad option values are
 given
Date: Thu, 03 Jun 2010 12:32:34 -0400
Message-ID: <4C07D922.7030302@RedHat.com>
References: <1275570134-24864-1-git-send-email-steved@redhat.com> <1275570134-24864-2-git-send-email-steved@redhat.com> <4C07B669.2040300@oracle.com> <4C07BE09.3060602@RedHat.com> <4C07D064.7070707@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755896Ab0FCRe7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 13:34:59 -0400
In-Reply-To: <4C07D064.7070707@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/03/2010 11:55 AM, Chuck Lever wrote:
> On 06/ 3/10 10:36 AM, Steve Dickson wrote:
>>
>>
>> On 06/03/2010 10:04 AM, Chuck Lever wrote:
>>> On 06/ 3/10 09:02 AM, Steve Dickson wrote:
>>>> mount.nfs should not only fail when an invalid option values
>>>> are supplied (as it does), it should also print a diagnostic
>>>> message identifying the problem
>>>>
>>>> Signed-off-by: Steve Dickson<steved@redhat.com>
>>>> ---
>>>>    utils/mount/network.c   |   20 ++++++++++++++++++--
>>>>    utils/mount/nfsumount.c |    4 +---
>>>>    2 files changed, 19 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>>> index c541257..d9903ed 100644
>>>> --- a/utils/mount/network.c
>>>> +++ b/utils/mount/network.c
>>>> @@ -1212,6 +1212,8 @@ nfs_nfs_program(struct mount_options *options,
>>>> unsigned long *program)
>>>>                return 1;
>>>>            }
>>>
>>> Another missed fall-through.
>> I realized this.. but if tmp<= 0, then the given value is invalid
>> so an error message should be displayed.
>>
>>>
>>>>        case PO_BAD_VALUE:
>>>> +        nfs_error(_("%s: invalid value for 'nfsprog=' option"),
>>>> +                progname);
>>>>            return 0;
>>>>        }
>>>>
>>>> @@ -1251,9 +1253,12 @@ nfs_nfs_version(struct mount_options *options,
>>>> unsigned long *version)
>>>>                }
>>>>                return 0;
>>>>            case PO_NOT_FOUND:
>>>> -            nfs_error(_("%s: option parsing error\n"),
>>>> +            nfs_error(_("%s: parsing error on 'vers=' option\n"),
>>>>                        progname);
>>>> +            return 0;
>>>>            case PO_BAD_VALUE:
>>>> +            nfs_error(_("%s: invalid value for 'vers=' option"),
>>>> +                    progname);
>>>>                return 0;
>>>>            }
>>>
>>> What I meant before is that, with this new code, this error diagnostic
>>> is displayed for "vers=booger" but not for "vers=12".  I think it should
>>> be displayed in both cases.
>> ah... This is not only routine where PO_FOUND is returned but the
>> value is invalid...
> 
> PO_FOUND here means the option was a keyword/value pair, and the value
> was numeric (but not necessarily a legal value for this option, so the
> caller has to do some range checking).  PO_BAD_VALUE means the option
> was a keyword/value pair, and the value wasn't numeric, and is thus
> definitely not valid.
> 
> PO_NOT_FOUND probably means the option was found, but the option isn't
> specified as a keyword/value; ie. "vers" by itself rather than "vers=n".
>  (Although you should check that, my recollection may be rusty).  Also
> invalid, and should be reported.
> 
> Or, PO_NOT_FOUND could mean the option wasn't found at all, but since
> po_rightmost() found it, that would be a software bug in this case.
I believe I'm understanding the logic... Whether the given
value is either a PO_BAD_VALUE (should be an integer and its not)
or a value that is out of range (the PO_FOUND cause), the given value 
is still "invalid"... 

PO_NOT_FOUND value is basically a parsing error and if its not recoverable as
with some cases, we should generate a message... 

So as long as we identify the above three cases and give a pointer to the
incorrect option, I think that will be fine...

steved.

