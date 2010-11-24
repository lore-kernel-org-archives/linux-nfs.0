Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55120 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab0KXJDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Nov 2010 04:03:10 -0500
Message-ID: <4CECD5B4.5090409@cn.fujitsu.com>
Date: Wed, 24 Nov 2010 17:07:00 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>
CC: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] libnfs.a: fix a bug when parse section's arg
References: <4CD36FE7.1010100@cn.fujitsu.com> <4CD8A5CF.4050007@cn.fujitsu.com> <4CEAA8EE.4090301@RedHat.com>
In-Reply-To: <4CEAA8EE.4090301@RedHat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Steve Dickson :
> On 11/08/2010 08:37 PM, Mi Jinlong wrote:
>> When parsing section's arg at configure file, the pointer 
>> should stop when fetch ']', and give the warning message.
> 
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>>  support/nfs/conffile.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
>> index 24640f4..798e5f3 100644
>> --- a/support/nfs/conffile.c
>> +++ b/support/nfs/conffile.c
>> @@ -271,9 +271,9 @@ conf_parse_line(int trans, char *line, size_t sz)
>>  		if (ptr == NULL)
>>  			return;
>>  		line = ++ptr;
>> -		while (*ptr && *ptr != '"')
>> +		while (*ptr && *ptr != '"' && *ptr != ']')
>>  			ptr++;
>> -		if (*ptr == '\0') {
>> +		if (*ptr == '\0' || *ptr == ']') {
>>  			xlog_warn("config file error: line %d: "
>>   				"non-matched '\"', ignoring until next section", ln);
>>  		}  else {
> I'm not seeing how this helps... I realize that with this
> patch we are saving the processing of a character or
> two... but what problem is this patch solving?

If user sets the section message as [ MountPoint "Mount_point ]"
for some mistake, the function should print the warning message,
but it continues with argument is "Mount_point ]".

After this patch, the function can process this problem correctly.

thanks,
Mi Jinlong

