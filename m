Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f170.google.com ([209.85.217.170]:63749 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbaDDXU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2014 19:20:26 -0400
Received: by mail-lb0-f170.google.com with SMTP id s7so2972426lbd.15
        for <linux-nfs@vger.kernel.org>; Fri, 04 Apr 2014 16:20:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHEKYV5xrv5ryh9oMyBT1y3kPDHHmif2f0rTA6DxPUbkSHf8eg@mail.gmail.com>
References: <CAHEKYV7JKuYaQv7c+CEtUZN+AXgR0XamphEtD+on1kw7FSiakg@mail.gmail.com>
	<20140319132423.GA18831@us.ibm.com>
	<CAHEKYV5xrv5ryh9oMyBT1y3kPDHHmif2f0rTA6DxPUbkSHf8eg@mail.gmail.com>
Date: Fri, 4 Apr 2014 19:20:24 -0400
Message-ID: <CAHEKYV6u8MHJkzx1S3-=nvYed+PMtLWWLCw0QskGaHeDSN93Nw@mail.gmail.com>
Subject: Re: Exporting partition mounted inside another
From: Mauricio Tavares <raubvogel@gmail.com>
To: Mauricio Tavares <raubvogel@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 19, 2014 at 11:18 PM, Mauricio Tavares <raubvogel@gmail.com> wrote:
> On Wed, Mar 19, 2014 at 9:24 AM, Malahal Naineni <malahal@us.ibm.com> wrote:
>> Mauricio Tavares [raubvogel@gmail.com] wrote:
>>>     I have in my NFSv4 server a directory called /exports where I
>>> place everything I want to export:
>>>
>>> /dev/vg1/logs            19.7G    651.0M     19.0G   3% /export/logs
>>> /dev/vg1/home           196.9G    163.8G     32.9G  83% /export/home
>>> /dev/vg1/pickles        504.0G     62.7G    441.2G  12% /export/home/pickles
>>> /dev/vg1/stuff           98.4G     21.9G     76.5G  22% /export/public
>>>
>>> Note that user pickles does have a lot of crap, so he gets to have his
>>> own partition. My own home dir is in /export/home/raub. Now, I export
>>> them as:
>>>
>>> spindizzy> cat /etc/exports
>>> /export 10.0.0.0/24(ro,fsid=0,no_subtree_check,sync)
>>> /export/logs 10.0.0.21/24(rw,insecure,root_squash,no_subtree_check,sync)
>>> /export/home 10.0.0.0/24(rw,insecure,root_squash,no_subtree_check,sync)
>>> /export/public 10.0.0.0/24(ro,insecure,root_squash,no_subtree_check,sync)
>>> spindizzy>
>>
>> You didn't export /export/home/pickles file system. Export that by
>> listing it in /etc/exports. Also, look at (crossmnt or no_hide options)
>>
>        Thanks for your reply. I added
>
> /export/home/pickles 10.0.0.0/24(rw,insecure,root_squash,no_subtree_check,sync)
>
> to /etc/exports and then did exportfs -r. Running exports told me it
> was being exported:
>
> spindizzy> exportfs
> /export         10.0.0.0/24
> /export/logs    10.0.0.21/24
> /export/home    10.0.0.0/24
> /export/home/pickles
>                 10.0.0.0/24
> /export/public  10.0.0.0/24
> spindizzy>
>
> If I go back to the desktop, it claims fileserver is exporting pickles:
>
> raub@desktop:~$ showmount -e fileserver
> Export list for fileserver:
> /export/public       10.0.0.0/24
> /export/home/pickles 10.0.0.0/24
> /export/home         10.0.0.0/24
> /export/logs         10.0.0.21/24
> /export              10.0.0.0/24
> raub@desktop:~$
>
> But, as before, when I tried to mount pickles, it doesn't:
>
> fileserver:/home/raub     197G  164G   33G  84% /home/raub
> fileserver:/home/pickles  197G  164G   33G  84% /home/pickles
>
> Same outcome with crossmnt or nohide
>
      Sorry for resurrecting the thread, but I am still clueless about
what is going on.

>>>
>>> and mount /export/user using automount,
>>>
>>> cat /etc/auto.home
>>> #
>>> # File: /etc/auto.home
>>> #
>>> *   -fstype=nfs4,hard,intr,rsize=8192,wsize=8192 fileserver:/home/&
>>>
>>> When I try to automount (say by logging in as saif user) pickles'
>>> homedir, it does not mount /dev/vg1/pickles. Instead, it just mounts
>>> it as if only existed in /dev/vg1/home/pickles in the fileserver:
>>>
>>> fileserver:/home/raub     197G  164G   33G  84% /home/raub
>>> fileserver:/home/pickles  197G  164G   33G  84% /home/pickles
>>>
>>> Sounds like I misconfigured my /etc/exports, but how?
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
