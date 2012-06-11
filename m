Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hop-nat-141.emc.com ([168.159.213.141]:42783 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750838Ab2FKTXd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 15:23:33 -0400
From: <david.noveck@emc.com>
To: <bharrosh@panasas.com>, <androsadamson@gmail.com>
CC: <andros@netapp.com>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@netapp.com>, <nfsv4@ietf.org>
Date: Mon, 11 Jun 2012 15:02:57 -0400
Subject: RE: [nfsv4] RFC 5661 LAYOUTRETURN clarification.
Message-ID: <5DEA8DB993B81040A21CF3CB332489F601BF59C653@MX31A.corp.emc.com>
References: <CAHVgHyUpM0rQWqO5-id+FohPKm1Lk=kkekf7HqzpfKcfvxx23A@mail.gmail.com>
 <4FD63BAF.8040107@panasas.com>
In-Reply-To: <4FD63BAF.8040107@panasas.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> And again, please explain why do you want it. What is wrong with the
> case we all agree with? ie: "Client can not call LAYOUTRETURN until
> all in-flight RPCs return, with or without an error"

It's a recipe for data corruption.  If, as Andy explained, he starts doing
IO's (let's suppose WRITEs) to the MDS any lingering WRITEs to the DS
since they reflect an earlier state of affairs can cause data corruption.

There are three ways to prevent those lingering DS writes from corrupting 
data:

1) Doing a LAYOUTRETURN
2) waiting until the IO's return.
3) "magically plugging the network interface".


Since there is no way to do 3), saying that you only can do 1) until after
2) is done is essentially going to mean:

a) that it may take a very long time:
b) that you will only do it, when it is no longer useful.

If you do 1) asap, then the lingering DS write problem is gone sooner,
and that's a good thing. 

-----Original Message-----
From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf Of Boaz Harrosh
Sent: Monday, June 11, 2012 2:41 PM
To: Andy Adamson
Cc: Andy Adamson; NFS list; Trond Myklebust; NFSv4
Subject: Re: [nfsv4] RFC 5661 LAYOUTRETURN clarification.

On 06/11/2012 07:01 PM, Andy Adamson wrote:

> I'm coding file layout data server recovery for the Linux NFS client,
> and came across an issue with LAYOUTRETURN that
> could use some comment from the list.
> 
> The error case I'm handling is an RPC layer dis-connection error
> during heavy WRITE i/o to a file layout data server. Our response is
> to internally mark the deviceid as invalid which prevents all pNFS
> calls using the deviceid - e.g. no new I/O using any layout that uses
> the invalid deviceid, and to redirect all I/O to the MDS (any queued
> RPC request that has not been sent is redirected to the MDS).
> 
> Plus - and here is where the clarification is needed - we immediately
> send a LAYOUTRETURN for any layout with in-flight requests to the
> dis-connected data server.  By in-flight I mean transmitted WRT the
> RPC layer.  The purpose of this LAYOUTRETURN is to notify the file
> layout MDS to fence the DS for the specified LAYOUTs, as the WRITEs
> will also be sent to the MDS.
> 


I do not disagree with this completely. The point here is very fine
grained and should be specified explicitly. I would like to see text
as of something like.

There are 3 types of in-flght RPC/IO
1. Client has sent RPC header + all of associated data and is waiting
   for DS WRITE/READ_DONE reply.

   (For me this case can be, client may return LAYOUTRETURN as your
    suggestion)

2. Client has sent the RPC header but has got stuck sending the rest
   of the RPC message. Then received a network disconnect. This is the
   most common part. Putting aside the RPC that got the error for a second.
   The most important is what to do with parallel RPC/IO which are in this
   state. Are parallel RPCs allowed to continue sending network packets
   after the LAYOUTRETURN was sent?

   The specific RPC that got stuck is not interesting because it's kind of
   1.5, We are not going to send any bytes on that channel. The interesting
   is these other DSs which are still streaming

3. Client has some internal RPC queue which do to some client parallelism
   will start sending RPC header + data after the LAYOUTRETURN was sent
   
What my point was that with the code you submitted we are clearly violating
2. and even 3. Because I do not see anything avoiding this.

And if the STD allows you 2 and 3. Then that's a big change to the concept.
Not like you let it seem.

> I contend that sending the LAYOUTRETURN in this error case does not
> violate the two sections of RFC 5661 below, as the client has stopped
> sending any I/O requests using the returned layout.
> 


I would not mind if this was true. That is if the LAYOUTRETURN was
a very clear barrier where our client would "magically" completely
plug the network interface and will not continue to send a single
byte on the wire to *any* DS involved with the layout. That's fine.

That is only allow sate 1 and 1.5 RPCs above. Some/all bytes where
presented on the wire, until the LAYOUTRETURN, from which point all
RPCs are hard aborted and not a single byte is sent.


> Others contend that since the in-flight RPCs reference the returned
> layout, the client is still 'using' the layout with these in-flight
> requests, and can not call LAYOUTRETURN until all in-flight RPCs
> return, with or without an error.
> 


With our client code I don't see how the guaranty of 2 and 3 above
will happen without actually implementing this here.

So in principal I agree with your principle, I only do not agree
with your practice. In your new code you are violating 2 and 3
which are not to be allowed.

And again, please explain why do you want it. What is wrong with the
case we all agree with? ie: "Client can not call LAYOUTRETURN until
all in-flight RPCs return, with or without an error"

Thanks
Boaz

> 
> Section 18.44.3 - the description section of the LAYOUTRETURN operation:
> 
>    After this call,
>    the client MUST NOT use the returned layout(s) and the associated
>    storage protocol to access the file data.
> 
> Section 13.6 Operations Sent to NFSv4.1 Data Servers
> 
>   As described in Section 12.5.1, a client
>   MUST NOT send an I/O to a data server for which it does not hold a
>   valid layout; the data server MUST reject such an I/O.
> 
> 
> -->Andy


_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

