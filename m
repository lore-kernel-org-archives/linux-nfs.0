From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsstat.c: Print diff stats every N seconds
Date: Sun, 15 Mar 2009 16:53:54 -0400
Message-ID: <20090315205354.GA26627@fieldses.org>
References: <1236909465-25818-1-git-send-email-kevin.constantine@disneyanimation.com> <49B9BE48.7080906@disney.com> <49B9D189.6090908@sgi.com> <49B9F340.5000809@disney.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>, linux-nfs@vger.kernel.org
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59850 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbZCOUyB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2009 16:54:01 -0400
In-Reply-To: <49B9F340.5000809-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 12, 2009 at 10:46:40PM -0700, Kevin Constantine wrote:
> Greg Banks wrote:
>> Kevin Constantine wrote:
>>> This patch to nfsstat.c allows for an optional argument to --sleep or
>>> -Z.  This optional argument is the interval at which differences in
>>> the nfsstat block are printed.
>>>
>>> [...]
>>>
>>> Moving to a listed output format instead of the traditional nfsstat
>>> output makes it trivial with a simple grep to watch the  stats that
>>> you really care about and ignore the rest.
>> Perhaps you could make that output format change a separate option, in a
>> separate patch from the optional argument to --sleep.  That way we can
>> argue their merits separately.  Also, a user could get the new output
>> format without specifying --sleep=N; if the new format is useful it's
>> worth having that.
>>
> Should the --list option patch be written against the --sleep[#] patch,  
> or against the current repo?

Just make it 2 patches that apply one after the other; I don't think the
order matters much, so I'd just do whatever's most convenient for you.

The revised patch looks fine to me, thanks.  Steve's the nfs-utils guy
(steved@redhat.com), so include him on the email when you've got a
version you want applied.

--b.

>
>
>>>
>>> @@ -223,7 +230,9 @@ void usage(char *name)
>>>    -v, --verbose, --all\tSame as '-o all'\n\
>>>    -r, --rpc\t\tShow RPC statistics\n\
>>>    -n, --nfs\t\tShow NFS statistics\n\
>>> -  -Z, --sleep\t\tSaves stats, pauses, diffs current and saved\n\
>>> +  -Z[#], --sleep[=#]    Saves stats, pauses, diffs current and saved.\n\
>>> +                      if # is provided, stats will be output every\n\
>>> +                # seconds\n\
>>>    -S, --since file\tShows difference between current stats and those
>>> in 'file'\n\
>>>    --version\t\tShow program version\n\
>>>    --help\t\tWhat you just did\n\
>>
>> This help text was already pretty clunky and clearly written by a
>> programmer.  Perhaps you could re-express it while you're here.
>>> @@ -245,7 +254,7 @@ static struct option longopts[] =
>>>
>>> @@ -258,6 +267,7 @@ main(int argc, char **argv)
>>>
>>> @@ -279,7 +289,7 @@ main(int argc, char **argv)
>>>
>>> @@ -311,6 +321,9 @@ main(int argc, char **argv)
>>>
>>> @@ -384,7 +397,7 @@ main(int argc, char **argv)
>>>
>> All this option handling looks good.
>>
>>> @@ -404,7 +417,33 @@ main(int argc, char **argv)
>>>              diff_stats(clientinfo_tmp, clientinfo, 0);
>>>          }
>>>      }
>>> +    if(sleep_time) {
>>> +        while(1) {
>>> +            if (opt_srv) {
>>> +                get_stats(NFSSRVSTAT, serverinfo_tmp , &opt_srv,
>>> opt_clt, 1);
>>> +                diff_stats(serverinfo_tmp, serverinfo, 1);
>>> +            }
>>> +            if (opt_clt) {
>>> +                get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt,
>>> opt_srv, 0);
>>> +                diff_stats(clientinfo_tmp, clientinfo, 0);
>>> +            }
>>> +            print_stats_list(opt_prt);
>>> +            fflush(stdout);
>>> +
>>> +            update_old_counters(clientinfo_tmp, clientinfo);
>>> +            sleep(sleep_time);
>>> +        }   +    }
>>> +    else {
>>> +        print_server_stats(opt_srv, opt_prt);
>>> +        print_client_stats(opt_clt, opt_prt);
>>> +    }
>>
>> The nfs-utils coding style is
>>
>>                         if (...) {
>>                                 ...
>>                         } else {
>>                                 ...
>>                         }
>>
>>
>>> +    return 0;
>>> +}
>>> +
>>> +static void
>>> +print_server_stats(int opt_srv, int opt_prt) {
>>
>> The nfs-utils coding style puts the opening brace { of a function on
>> it's own line.
>>>  
>>>
>>> @@ -515,10 +556,42 @@ main(int argc, char **argv)
>>>                  );
>>>          }
>>>      }
>>> -
>>> -    return 0;
>>>  }
>>>
>>> +static void
>>> +print_stats_list(int opt_prt) {
>>>
>> Looks ok on a quick scan.
>>> +
>>> +    for (i = 0, srvtotal = 0, clttotal = 0; i < nr; i++) {
>>> +        if (srvinfo[i])
>>> +            srvtotal += srvinfo[i];
>>> +        if (cltinfo[i])
>>> +            clttotal += cltinfo[i];
>> The if()s here are superfluous.
>>
>> I don't see an update to the manpage.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
