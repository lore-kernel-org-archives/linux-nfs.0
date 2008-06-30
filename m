From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 11:25:39 -0400
Message-ID: <76bd70e30806300825t6490477dpb8ce3ee48a0a6777@mail.gmail.com>
References: <76bd70e30806270706x7cbfd291l6cb6d0cc5e81771@mail.gmail.com>
	 <OF8CAC1A08.19AB248E-ON65257478.003203B5-65257478.0036AF80@in.ibm.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	"Peter Staubach" <staubach@redhat.com>
To: "Krishna Kumar2" <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:53468 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbYF3PZl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 11:25:41 -0400
Received: by yw-out-2324.google.com with SMTP id 9so774349ywe.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 08:25:40 -0700 (PDT)
In-Reply-To: <OF8CAC1A08.19AB248E-ON65257478.003203B5-65257478.0036AF80@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 5:57 AM, Krishna Kumar2 <krkumar2@in.ibm.com> wrote:
> chucklever@gmail.com wrote on 06/27/2008 07:36:44 PM:
>
>> > But loopback is better than actual network traffic.
>>
>> What precisely do you mean by that?
>
> Sorry I was not clear. I meant that the loopback will be better than
> actual traffic between different server/client.
>
>> You are testing with the client and server on the same machine.  Is
>> the loopback mount over the lo interface, but you mount the machine's
>> actual IP address for the "network" test?
>
> Actually isn't that the same? I am using localhost in any case.

As I understand it, "lo" is effectively a virtualized network device
with point-to-point routing.  Looping back through a real NIC can, in
many cases, go all the way down to the network hardware and back, and
is likely subject to routing decisions in your system's network layer.
 So I would expect them to be different in most cases.

>> It would be interesting to compare a network-only performance test
>> (like iPerf) for loopback and for going through the NIC.
>
> iperf (one thread, 64K I/O size, 30 secs):
>      NIC: 445 MB/s
>      Loopback: 735 MB/s

-- 
Chuck Lever
