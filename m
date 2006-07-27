From: "Jose R. Santos" <jrs@us.bim.com>
Subject: Re: [NFS] [ltc-perf] draft of nfs event hook
Date: Thu, 27 Jul 2006 12:01:09 -0500
Message-ID: <44C8F155.5000000@us.bim.com>
References: <OF053E04B8.D96A9ADC-ON482571B7.0031B2AD-482571B7.00323E27@cn.ibm.com> 	 <44C8C631.40003@cn.ibm.com> <76bd70e30607270829q500711c8k8e7dd6ba9a9b6dfe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Li Guanglei <guanglei@cn.ibm.com>,         "systemtap@sourceware.org" <systemtap@sourceware.org>,         nfs@lists.sourceforge.net
Return-path: <systemtap-return-3833-gls-systemtap=m.gmane.org@sourceware.org>
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30607270829q500711c8k8e7dd6ba9a9b6dfe@mail.gmail.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <nfs.lists.sourceforge.net>

Chuck Lever wrote:
> On 7/27/06, Li Guanglei <guanglei@cn.ibm.com> wrote:
>>    When we started working on NFS trace hooks, we realized it is not
>> an easy task. Although we use NFS in daily work but we don't have much
>> knowledge about the NFS protocol details and its implementation inside
>> the Kernel. So I divided the work into two steps. At the first step I
>> need get a list of trace points. And at the second step I need to make
>> sure what trace data is available for each trace hook. In a short, the
>> trace data available for each hook will be derived from the arguments
>> of the kernel functions being probed.
>>
>>    We read through the Kernel source code and chose some functions to
>> be instrumented. We will trace the entry of these functions and if
>> necessary, the return of them will also be traced. The following is
>> the list of these functions, please take a review:
>
> Have you done this with a local file system?  I assume yes, and that
> you just described the general approach you have taken with other file
> systems.  I think getting the same kind of data and trace points from
> the NFS client as you added to local file systems would be good.

There is someone already working on a tapset for ext3 and we are waiting 
for that tapset to be available before we go into looking how to add 
trace hooks to ext3.  We plan to have a similar approach to the NFS hooks.
>
> Capturing VFS and address space entry points is definitely useful and
> is similar to local file systems.  At the bottom of the NFS client is
> the RPC client, and it acts just like the block I/O layer does for
> local file systems.  Would you consider adding trace points in the
> LKET for the RPC client and server?

Definitely.  We've already added a trace hook on the NFS server dispatch 
entry and exit and we are looking at adding even more.  While our focus 
has mostly been adding hooks that would assist in performance analysis, 
the tool can also be used for the purposes of debugging as well.  If you 
have specific places where you would like to see trace hook inserted, we 
are definitely interested.

-JRS
