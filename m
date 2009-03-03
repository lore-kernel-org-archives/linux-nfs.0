From: David Bartley <dtbartle@csclub.uwaterloo.ca>
Subject: Re: Locked system
Date: Tue, 3 Mar 2009 16:38:04 -0500
Message-ID: <e77a196d0903031338q417688a0vb8a5383f4c6f7e79@mail.gmail.com>
References: <e77a196d0902241947wdaaa021le11d11fd607f60bc@mail.gmail.com>
	<e77a196d0903021909w78b426f1kcb2a69b6fad58abf@mail.gmail.com>
	<20090303173443.GI22184@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090303173443.GI22184@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 3, 2009 at 12:34 PM, J. Bruce Fields <bfields@fieldses.org> wro=
te:
> On Mon, Mar 02, 2009 at 10:09:57PM -0500, David Bartley wrote:
>> Hi,
>>
>> I'm wondering if anybody has had a chance to look at this?
>
> What's the client kernel version? =A0What's the server? =A0Can you get a
> network trace? =A0(tcpdump -s0 -wTMP, send us TMP).

The client's kernel version is 2.6.27 (2.6.27-11-generic from Ubuntu).
The server is OpenSolaris. I don't know how to reproduce this, so I
can't send you a trace.

Thanks,
David

>
> --b.
>
>>
>> Thanks,
>> David
>>
>> On Tue, Feb 24, 2009 at 10:47 PM, David Bartley
>> <dtbartle@csclub.uwaterloo.ca> wrote:
>> > Hello,
>> >
>> > A system I administer partially locked due to an apparent NFS4
>> > problem. I've attached the trace I found in kern.log. Let me know if
>> > you need any additional information.
>> >
>> > -- David
>> >
>
>
