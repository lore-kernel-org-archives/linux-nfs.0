Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:52688 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759800Ab2HIXFh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 19:05:37 -0400
Received: by ggdk6 with SMTP id k6so1078491ggd.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 16:05:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344539545.25447.63.camel@lade.trondhjem.org>
References: <CABpMAyL-B9Kqg8O4xxxtj0X8PF7fP4TM+NnLA_Ynhm-_3C6MUg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9380987@SACEXCMBX04-PRD.hq.netapp.com>
 <CABpMAyKddCjhWe-LjFOJrikLnC+BJ7GsAMAvieh1rabDPiA=Ug@mail.gmail.com>
 <1344528377.25447.29.camel@lade.trondhjem.org> <CABpMAyL-AnLc1rbPEtaBNONKiwsFayYXsGt+dPnDyua0zfS81w@mail.gmail.com>
 <1344539545.25447.63.camel@lade.trondhjem.org>
From: Idan Kedar <idank@tonian.com>
Date: Fri, 10 Aug 2012 02:04:54 +0300
Message-ID: <CABpMAyKRFjr5Pwr6NVBMN6WqVvnSsGcnCFr2X14k29pMWrbH8g@mail.gmail.com>
Subject: Re: return layout on error, BUG/deadlock
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 10:12 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2012-08-09 at 19:54 +0300, Idan Kedar wrote:
>> On Thu, Aug 9, 2012 at 7:06 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Thu, 2012-08-09 at 18:49 +0300, Idan Kedar wrote:
>> >> On Thu, Aug 9, 2012 at 5:05 PM, Myklebust, Trond
>> >> <Trond.Myklebust@netapp.com> wrote:
>> >> >> -----Original Message-----
>> >> >> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> >> >> owner@vger.kernel.org] On Behalf Of Idan Kedar
>> >> >> Sent: Thursday, August 09, 2012 9:03 AM
>> >> >> To: Boaz Harrosh; NFS list
>> >> >> Cc: Benny Halevy
>> >> >> Subject: return layout on error, BUG/deadlock
>> >> >>
>> >> >> Hi,
>> >> >>
>> >> >> As a result of some experiments, I wanted to see what happens when I
>> >> >> inject an error (hard coded) to the object layout driver. the patch is at the
>> >> >> bottom of this mail. the reason I did this is because when I inject errors in my
>> >> >> modified version of the object layout driver, I get the same BUG Tigran
>> >> >> reported about yesterday:
>> >> >> nfs4proc.c:6252 :   BUG_ON(!list_empty(&lo->plh_segs));
>> >> >>
>> >> >> In my modified version (based on kernel 3.3), the bug seems to be that
>> >> >> pnfs_ld_write_done calls pnfs_return_layout in the error path, even if there
>> >> >> is in-flight I/O.
>> >> >
>> >> > That is not a bug. It is an intentional change in order to allow the MDS to fence off the outstanding writes (if it can do so) before we retransmit them as write-through-MDS. Otherwise, you risk races between the outstanding writes-to-DS and the new writes-through-MDS.
>> >>
>> >> to what change are you referring?
>> >
>> > As I stated in the changelog of the patch that I sent to the list
>> > yesterday, the behaviour is due to commit 0a57cdac3f.
>> >
>>
>> I'm not sure I'm following. I was talking about the state of the code
>> v3.5, not to any specific patch/change. since the client yelled
>> "BUG!!!" and crashed, there is some bug involved, either because the
>> BUG() is correct or because the presence of the BUG() is the bug
>> itself.
>>
>> >> >
>> >> > See the changelog in the patch that I sent to the list yesterday.
>> >> >
>> >>
>> >> I saw that, and if I'm not mistaken these races apply to object layout
>> >> as well, and in any case they apply in my case. However, it is not
>> >> easy to mess around with LAYOUTRETURN in object layout, and there have
>> >> been several discussions on the issue. In one of these discussions
>> >> Benny clarified that the object layout client must wait for all
>> >> in-flight I/O to end.
>> >
>> > If the problem is that the DS is failing to respond, how does the client
>> > know that the in-flight I/O has ended?
>> >
>>
>> after the last rpc_call_done is called there is no I/O from the
>> client's perspective an the layout can be safely returned, after which
>> I/O can be done through the MDS.
>
> No. You are confused.
>
> Being in rpc_call_done just tells you that the client thinks it is done.
> It tells you nothing about what the DS is doing. It may just slooooowly
> be processing the WRITE calls for all you know.
>

That's what I meant by "from the client's perspective". At this point,
the client can say "I'm not *using* this layout anymore" because even
if some I/O on its way to the DS originates in the client, the client
can't do anything about it. The fate of this I/O is meaningless to the
client at that point. This is the best the client can do to help the
MDS preserve integrity - keep the layout as long as it has information
about its I/O.

> Unless you get a response from the DS saying "I'm done", or you have
> some other mechanism to guarantee that the DS is done when you time out,
> then you have no guarantee that it is safe to send to MDS.
>

Exactly. What if I don't have such a mechanism? My options are:
* Ask the MDS to somehow fence in-flight I/O and resend through the MDS.
* Return an error to the user.
What if the server does not support fencing? In that case we shouldn't
send through MDS while there is in-flight I/O. Do we want to assume
fencing is implemented? And if fencing isn't implemented and we return
an error to the user - how do we know when it is safe to perform any
I/O again?
And even if fencing is implemented, I don't think the client should
rely on it, because the whole idea beind pNFS is a smart client that
offloads what it can from the servers.

>> Is there I/O pending from the DS perspective? maybe, but all you can
>> do is send I/O via MDS and hope it will not race. fencing doesn't
>> really save you, it just improves your odds where applicable, i.e.
>> file layout.

One correction to what I said: Fencing does save you, if it's
implemented. LAYOUTRETURN doesn't save you (when fencing is not
implemented).

>
> Actually, when reading the iSCSI spec, it implies that there is a known
> session timeout that is negotiated between the initiator and target.
> After the session expires, you are guaranteed that no further commands
> are running on the DS.
>
> The iFCP protocol attaches a timeout value to each frame, and is
> supposed to enforce that timeout.
>
> So at least those protocols should have a deterministic behaviour that
> can be used by the client.
>
>> >> So for file layout it probably makes sense, but object layout (and if
>> >> I understand correctly, block layout as well) something else needs to
>> >> be done. I thought about sync wait when returning the layout on error,
>> >> but according to Boaz it will cause deadlocks (Boaz - can you please
>> >> elaborate?).
>> >
>> > The object layoutreturn has the ability to pass a timeout error value to
>> > the MDS precisely in order to allow the latter to deal with this kind of
>> > issue. See the description of struct pnfs_osd_ioerr4 in rfc5664.
>> >
>> > The block layout is adding the same ability to layoutreturn in NFSv4.2
>> > (see draft-ietf-nfsv4-minorversion2-13.txt) via the struct
>> > layoutreturn_device_error4, so presumably they too have a plan for
>> > dealing with this kind of issue.
>> >

Then on layoutreturn we could call a new layout driver method, end_io
or something returns only when there is no danger of race (either by
waiting for in-flight I/O to complete/timeout/error out or by fencing)
and only then return the layout. This works for me. I don't know if it
works for Boaz though.

>>
>> I'll wait for Boaz (or someone else) to explain what exactly is "this
>> kind of issue". I still don't know why sync wait would deadlock.
>>
>> >> And come to think of it, nfs4_proc_setattr also returns the layout
>> >> when there may be I/O in-flight (correct me if i'm wrong). So I guess
>> >> pnfs_return_layout should somehow solve this by itself by saying "if
>> >> this is fencing (a flag which will be set for file layout only), go
>> >> ahead, otherwise make the layout as 'needs to be returned' and when
>> >> the lseg lists gets empty return the layout".
>> >
>> > The only layout type that sets the PNFS_LAYOUTRET_ON_SETATTR flag is
>> > objects, so that question needs to be directed to Boaz.
>> >
>>
>> Yes, this entire thread is mainly directed to Boaz... And IIRC he did
>> want to implement something of that sort, and this thread was
>> basically for asking him "did you?".
>>
>> > --
>> > Trond Myklebust
>> > Linux NFS client maintainer
>> >
>> > NetApp
>> > Trond.Myklebust@netapp.com
>> > www.netapp.com
>> >
>>
>>
>>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>



-- 
idank
