From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [Patch 2/10] NFS Mount Configuration File (Vers 3)
Date: Sat, 08 Aug 2009 23:52:35 +0300
Message-ID: <4A7DE593.10708@panasas.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B23D2.6080900@RedHat.com> <4A7BE0B2.9010008@panasas.com> <4A7C6032.4060301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2233
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750898AbZHHUwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Aug 2009 16:52:44 -0400
In-Reply-To: <4A7C6032.4060301-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 07, 2009, 20:11 +0300, Steve Dickson <SteveD@redhat.com> wrote:
> 
> On 08/07/2009 04:07 AM, Benny Halevy wrote:
>> On Aug. 06, 2009, 21:41 +0300, Steve Dickson <SteveD@redhat.com> wrote:
>>> commit f6f4d0b872c01eaffbcb4c3919f13237aa8678e1
>>> Author: Steve Dickson <steved@redhat.com>
>>> Date:   Mon Mar 9 13:55:25 2009 -0400
>>>
>>>     Taught conf_parse_line() to ignore spaces in the
>>>      '[section]' parsing and before the assignment statements
>>>     
>>>     Signed-off-by: Steve Dickson <steved@redhat.com>
>>>
>>> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
>>> index c5f9fa7..5f491eb 100644
>>> --- a/support/nfs/conffile.c
>>> +++ b/support/nfs/conffile.c
>>> @@ -50,11 +50,6 @@
>>>  #include "xlog.h"
>>>  
>>>  static void conf_load_defaults (int);
>>> -#if 0
>>> -static int conf_find_trans_xf (int, char *);
>>> -#endif
>>> -
>>> -size_t  strlcpy(char *, const char *, size_t);
>>>  
>>>  struct conf_trans {
>>>  	TAILQ_ENTRY (conf_trans) link;
>>> @@ -219,26 +214,48 @@ conf_parse_line(int trans, char *line, size_t sz)
>>>  	if (*line == '#' || *line == ';')
>>>  		return;
>>>  
>>> +	/* Ignore blank lines */
>>> +	if (*line == '\0')
>>> +		return;
>>> +
>>> +	/* Strip off any leading blanks */
>>> +	while (isblank(*line)) 
>>> +		line++;
>>> +
>> Why not do this before looking for '#' or ';'?
> Point, if we supported in-line comments or am I missing 
> something? 

Right.  This will allow the comment to start after a string
of white spaces.  It's not the most important feature but
will allow more readable config file, I think.

Benny

> 
> steved.
> 
