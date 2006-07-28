From: Li Guanglei <guanglei@cn.ibm.com>
Subject: Re: [NFS] [ltc-perf] draft of nfs event hook
Date: Fri, 28 Jul 2006 10:03:53 +0800
Message-ID: <44C97089.3080901@cn.ibm.com>
References: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com><44C8C631.40003@cn.ibm.com><76bd70e30607270829q500711c8k8e7dd6ba9a9b6dfe@mail.gmail.com> <44C94266.6070606@cn.ibm.com> <001301c6b1e8$bd7cf590$160b0a0a@ict25eacacc325>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "systemtap@sourceware.org" <systemtap@sourceware.org>,         nfs@lists.sourceforge.net
Return-path: <systemtap-return-3839-gls-systemtap=m.gmane.org@sourceware.org>
To: ZhaoYi <zhaoyi@ncic.ac.cn>
In-Reply-To: <001301c6b1e8$bd7cf590$160b0a0a@ict25eacacc325>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <nfs.lists.sourceforge.net>

ZhaoYi ??:
> I think RPC is also needed to be listed, because in the current implementation of Linux NFS, RPC in the kernel is used by nfs only.

Although RPC is only used by NFS inside Kernel, I think NFS and RPC 
fall into two different categories. A separate set of trace hooks for 
RPC should be better.

- Guanglei

> ----- Original Message ----- 
> From: "Li Guanglei" <guanglei@cn.ibm.com>
> To: "Chuck Lever" <chucklever@gmail.com>
> Cc: <nfs@lists.sourceforge.net>; <systemtap@sourceware.org>
> Sent: Friday, July 28, 2006 6:47 AM
> Subject: Re: [NFS] [ltc-perf] draft of nfs event hook
> 
> 
>>> Have you done this with a local file system?  I assume yes, and that
>>> you just described the general approach you have taken with other file
>>> systems.  I think getting the same kind of data and trace points from
>>> the NFS client as you added to local file systems would be good.
>>>
>>> Capturing VFS and address space entry points is definitely useful and
>>> is similar to local file systems.  At the bottom of the NFS client is
>>> the RPC client, and it acts just like the block I/O layer does for
>>> local file systems.  Would you consider adding trace points in the
>>> LKET for the RPC client and server?
>>>
>>>>    What I didn't list about NFS operations includes authentication,
>>>> NFSv4 callback and RPC(I prefer to use a separate set of trace hooks
>>>> for RPC). I am not sure if these operations are also required to be
>>>> traced. If I missed some important functions or I listed some
>>>> redundant functions, please feel free to let me know. Any comments
>>>> will be highly appreciated.
>>>>
>> I didn't list RPC here because I think RPC is not only used by NFS and 
>> I need another set of RPC trace hooks to address the RPC server and 
>> client side operations. That will be my plan of the next set of trace 
>> hooks.
>>
>> - Guanglei
>>
>>
>> -------------------------------------------------------------------------
>> Take Surveys. Earn Cash. Influence the Future of IT
>> Join SourceForge.net's Techsay panel and you'll get the chance to share your
>> opinions on IT & business topics through brief surveys -- and earn cash
>> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>>
