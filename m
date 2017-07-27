Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:37394 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdG0QG7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jul 2017 12:06:59 -0400
Received: by mail-oi0-f65.google.com with SMTP id j194so10219477oib.4
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 09:06:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5c0d7c27-8bc1-49a0-2169-ea943589b0ac@RedHat.com>
References: <1501142364-14033-1-git-send-email-chunyu.wang.1995@gmail.com> <5c0d7c27-8bc1-49a0-2169-ea943589b0ac@RedHat.com>
From: ChunYu Wang <chunyu.wang.1995@gmail.com>
Date: Fri, 28 Jul 2017 00:06:58 +0800
Message-ID: <CAPu2Jx1DE9Y6_ftp3_9vmzew7SYmTrO2BKZTX2jrZWpUXEfLhg@mail.gmail.com>
Subject: Re: [PATCH] rpcdebug: Add proper free() to avoid memory leak
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maybe we can not trust valgrind? Or I have just misunderstood what did
the valgrind report.

As I have just added enough free(cdename) statements before exit,
valgrind will not report "still reachable" any more.

Since I am not sure of whether this kind of report by valgrind should
be treated as potential leaks, please help me to judge!

Thanks,
- Chunyu

On Thu, Jul 27, 2017 at 10:48 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> On 07/27/2017 03:59 AM, ChunYu Wang wrote:
>> rpcdebug.c use char* cdename to store program name:
>>
>>     cdename = malloc(strlen(basename(argv[0])));
>>     strcpy(cdename, basename(argv[0]));
>>
>> It is better to free before exit to avoid potential leaks.
> I guess I don't understand how memory can be leaked
> when a process is exiting... What am I missing?
>
> steved.
>>
>> Signed-off-by: ChunYu Wang <chunyu.wang.1995@gmail.com>
>> ---
>>  tools/rpcdebug/rpcdebug.c | 9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
>> index 68206cc..722ab4d 100644
>> --- a/tools/rpcdebug/rpcdebug.c
>> +++ b/tools/rpcdebug/rpcdebug.c
>> @@ -131,6 +131,7 @@ main(int argc, char **argv)
>>               print_flags(stdout, module, ~(unsigned int) 0, 1);
>>       }
>>
>> +     free(cdename);
>>       return 0;
>>  }
>>
>> @@ -221,6 +222,7 @@ find_flag(char **module, char *name)
>>                               "please specify the module name using\n"
>>                               "the -m option.\n",
>>                               cdename, name);
>> +                     free(cdename);
>>                       exit(1);
>>               }
>>               value = flagmap[i].value;
>> @@ -238,6 +240,7 @@ find_flag(char **module, char *name)
>>                       fprintf(stderr,
>>                               "%s: unknown flag %s\n",
>>                               cdename, name);
>> +             free(cdename);
>>               exit(1);
>>       }
>>
>> @@ -255,10 +258,12 @@ get_flags(char *module)
>>
>>       if ((sysfd = open(filename, O_RDONLY)) < 0) {
>>               perror(filename);
>> +             free(cdename);
>>               exit(1);
>>       }
>>       if ((len = read(sysfd, buffer, sizeof(buffer))) < 0) {
>>               perror("read");
>> +             free(cdename);
>>               exit(1);
>>       }
>>       close(sysfd);
>> @@ -278,14 +283,17 @@ set_flags(char *module, unsigned int value)
>>       len = sprintf(buffer, "%d", value);
>>       if ((sysfd = open(filename, O_WRONLY)) < 0) {
>>               perror(filename);
>> +             free(cdename);
>>               exit(1);
>>       }
>>       if ((ret = write(sysfd, buffer, len)) < 0) {
>>               perror("write");
>> +             free(cdename);
>>               exit(1);
>>       }
>>       if (ret < len) {
>>               fprintf(stderr, "error: short write in set_flags!\n");
>> +             free(cdename);
>>               exit(1);
>>       }
>>       close(sysfd);
>> @@ -359,6 +367,7 @@ usage(int excode, char *module)
>>         else
>>           fprintf(stderr, "       (use %s -vh to get a list of modules and valid flags)\n", cdename);
>>       }
>> +     free(cdename);
>>       exit (excode);
>>  }
>>
>>
