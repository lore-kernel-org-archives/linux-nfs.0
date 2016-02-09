Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755446AbcBIQAw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2016 11:00:52 -0500
Subject: Re: [PATCH] Ignore whitespace at the beginning of option tags
To: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <1454020727-1814-1-git-send-email-malahal@us.ibm.com>
 <56B0CA44.40105@RedHat.com>
 <alpine.OSX.2.19.9992.1602030655230.16954@planck.local>
 <20160204232956.GA1290@us.ibm.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56BA0D32.7080209@RedHat.com>
Date: Tue, 9 Feb 2016 11:00:50 -0500
MIME-Version: 1.0
In-Reply-To: <20160204232956.GA1290@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/04/2016 06:29 PM, Malahal Naineni wrote:
> Sorry Steve, Ben is right. It is based on
> "git://git.linux-nfs.org/projects/steved/libnfsidmap.git"
> 
> Do I need to re-clone my repo with something else?
No... You are good... Committed!

I'm thinking we should probably roll libnfsidmap into
nfs-utils as a .a lib... The only binary using it,
to my knowledge, is rpc.idmapd and I don't think
we really want anybody else using it... 

Thoughts?

steved.
 

> 
> Regards, Malahal.
> 
> Benjamin Coddington [bcodding@redhat.com] wrote:
>> On Tue, 2 Feb 2016, Steve Dickson wrote:
>>>
>>> On 01/28/2016 05:38 PM, Malahal Naineni wrote:
>>>> The following should work now:
>>>>
>>>> [General]
>>>> 	Domain = local.domain.edu
>>>>
>>>> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
>>>> ---
>>>>  cfg.c | 9 ++++++++-
>>> Ok.. I give... :-) What is this patch relative to? There is
>>> a conf_parse_line() in support/nfs/conffile.c but there
>>> is no cfg.c file in nfs-utils... and this patch does
>>> not apply...
>>
>> This is for libnfsidap..  cc-ing Bruce.
>>
>> Ben
>>
>>>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/cfg.c b/cfg.c
>>>> index c615d24..e0ab839 100644
>>>> --- a/cfg.c
>>>> +++ b/cfg.c
>>>> @@ -210,6 +210,7 @@ static void
>>>>  conf_parse_line (int trans, char *line, size_t sz)
>>>>  {
>>>>    char *val;
>>>> +  char *tag;
>>>>    size_t i;
>>>>    int j;
>>>>    static char *section = 0;
>>>> @@ -262,8 +263,14 @@ conf_parse_line (int trans, char *line, size_t sz)
>>>>  	/* Skip trailing whitespace, if any */
>>>>  	for (j = sz - (val - line) - 1; j > 0 && isspace (val[j]); j--)
>>>>  	  val[j] = '\0';
>>>> +
>>>> +	/* Skip beginning white space */
>>>> +	tag = line;
>>>> +	while (isspace(*tag))
>>>> +		tag++;
>>>> +
>>>>  	/* XXX Perhaps should we not ignore errors?  */
>>>> -	conf_set (trans, section, line, val, 0, 0);
>>>> +	conf_set (trans, section, tag, val, 0, 0);
>>>>  	return;
>>>>        }
>>>>
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
