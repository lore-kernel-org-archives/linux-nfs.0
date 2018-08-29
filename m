Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:38982 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727554AbeH2R6n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Aug 2018 13:58:43 -0400
Received: by mail-vk0-f43.google.com with SMTP id e139-v6so2563106vkf.6
        for <linux-nfs@vger.kernel.org>; Wed, 29 Aug 2018 07:01:37 -0700 (PDT)
MIME-Version: 1.0
References: <0D862469-B678-4827-B75D-69557734D34F@uvensys.de>
 <93486E63-F27E-4F45-9C43-ECEA66A46183@uvensys.de> <D480748B-967F-421C-8749-914CBD38C995@gmail.com>
 <79933889-D7B8-4E8D-989F-297FD411644E@uvensys.de> <989D72C4-553B-46CD-AE3F-4EB5BDEDB2BE@oracle.com>
 <CAN-5tyH1B1B_JMVFag9=-uwckt2HYyAfotsjkwksf9bvknqqJw@mail.gmail.com> <840C83A0-1411-46D3-9370-431CFEDE0D93@uvensys.de>
In-Reply-To: <840C83A0-1411-46D3-9370-431CFEDE0D93@uvensys.de>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 29 Aug 2018 10:01:24 -0400
Message-ID: <CAN-5tyFnvkuL-uyGAcAvEgteByhBsmheWfZg4U70AuGWEw6mKQ@mail.gmail.com>
Subject: Re: Question about nfs in infiniband environment
To: v.lieder@uvensys.de
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Volker,

The issue was trigger from the following set of events. NFSoRDMA
connection over softRoCE was experiencing problems. There was a gap of
3mins between the last operation (OPEN) in the network trace and
(because RDMA connection was re-established) the BIND_CONN_TO_SESSION
which got the BAD_SESSION error. Client's lease has expired in 3mins
so that explains the BAD_SESSION error.

Then after the client notices that the session is bad and recovers
clientid and session and starts state recovery. When client sends the
recovery of OPEN the server sends NO_GRACE so client switches from
reboot recovery to no-grace recovery which includes testing the
stateid before sending the open. That's why we are sending the old
stateid (from the old client id) and gets that error and logs that
message in var log messages.

A network trace would be needed from your environment to tell if this
is a similar situation.
On Wed, Aug 29, 2018 at 5:03 AM Volker Lieder <v.lieder@uvensys.de> wrote:
>
> Hi Olga,
>
> i dont have a redhat account.
>
> Can you, if helpful, paste the result right here?
>
> Regards
> Volker
>
> > Am 28.08.2018 um 21:10 schrieb Olga Kornievskaia <aglo@umich.edu>:
> >
> > On Tue, Aug 28, 2018 at 11:41 AM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >>
> >>
> >>> On Aug 28, 2018, at 11:31 AM, Volker Lieder <v.lieder@uvensys.de> wrote:
> >>>
> >>> Hi Chuck,
> >>>
> >>>> Am 28.08.2018 um 17:26 schrieb Chuck Lever <chucklever@gmail.com>:
> >>>>
> >>>> Hi Volker-
> >>>>
> >>>>
> >>>>> On Aug 28, 2018, at 8:37 AM, Volker Lieder <v.lieder@uvensys.de> wrote:
> >>>>>
> >>>>> Hi,
> >>>>>
> >>>>> a short update from our site.
> >>>>>
> >>>>> We resized CPU and RAM on the nfs server and the performance is good right now and the error messages are gone.
> >>>>>
> >>>>> Is there a guide what hardware requirements a fast nfs server has?
> >>>>>
> >>>>> Or an information, how many nfs prozesses are needed for x nfs clients?
> >>>>
> >>>> The nfsd thread count depends on number of clients _and_ their workload.
> >>>> There isn't a hard and fast rule.
> >>>>
> >>>> The default thread count is probably too low for your workload. You can
> >>>> edit /etc/sysconfig/nfs and find "RPCNFSDCOUNT". Increase it to, say,
> >>>> 64, and restart your NFS server.
> >>>
> >>> I tried this, but then the load on the "small" server was to high to serve further requests, so that was the idea to grow this up.
> >>
> >> That rather suggests the disks are slow. A deeper performance
> >> analysis might help.
> >>
> >>
> >>>> With InfiniBand you also have the option of using NFS/RDMA. Mount with
> >>>> "proto=rdma,port=20049" to try it.
> >>>
> >>> Yes, thats true, but in the mellanox driver set they disabled nfsordma in Version 3.4.
> >>
> >> Not quite sure what you mean by "mellanox driver". Do you
> >> mean MOFED? My impression of the stock CentOS 7.5 code is
> >> that it is close to upstream, and you shouldn't need to
> >> replace it except in some very special circumstances (high
> >> end database, eg).
> >>
> >>
> >>> It should work with centos driver, but we didnt tested it right now in newer setups.
> >>>
> >>> One more question, since other problems seem to be solved:
> >>>
> >>> What about this message?
> >>>
> >>> [Tue Aug 28 15:10:44 2018] NFSD: client 172.16.YY.XXX testing state ID with incorrect client ID
> >>
> >> Looks like an NFS bug. Someone else on the list should be able
> >> to comment.
> >
> > I ran into this problem while testing RHEL7.5 NFSoRDMA (over
> > SoftRoCE). Here's a bugzilla
> > https://bugzilla.redhat.com/show_bug.cgi?id=1518006
> >
> > I was having a hard time reproducing it consistently to debug it.
> > Because it was really a non-error error (and it wasn't upstream), it
> > went on a back burner.
> >
> >>
> >>
> >>>>> Best regards,
> >>>>> Volker
> >>>>>
> >>>>>> Am 28.08.2018 um 09:45 schrieb Volker Lieder <v.lieder@uvensys.de>:
> >>>>>>
> >>>>>> Hi list,
> >>>>>>
> >>>>>> we have a setup with round about 15 centos 7.5 server.
> >>>>>>
> >>>>>> All are connected via infiniband 56Gbit and installed with new mellanox driver.
> >>>>>> One server (4 Core, 8 threads, 16GB) is nfs server for a disk shelf with round about 500TB data.
> >>>>>>
> >>>>>> The server exports 4-6 mounts to each client.
> >>>>>>
> >>>>>> Since we added 3 further nodes to the setup, we recieve following messages:
> >>>>>>
> >>>>>> On nfs-server:
> >>>>>> [Tue Aug 28 07:29:33 2018] rpc-srv/tcp: nfsd: sent only 224000 when sending 1048684 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:30:13 2018] rpc-srv/tcp: nfsd: sent only 209004 when sending 1048684 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:30:14 2018] rpc-srv/tcp: nfsd: sent only 204908 when sending 630392 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:32:31 2018] rpc-srv/tcp: nfsd: got error -11 when sending 524396 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:32:33 2018] rpc-srv/tcp: nfsd: got error -11 when sending 308 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:32:35 2018] rpc-srv/tcp: nfsd: got error -11 when sending 172 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:32:53 2018] rpc-srv/tcp: nfsd: got error -11 when sending 164 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:38:52 2018] rpc-srv/tcp: nfsd: sent only 749452 when sending 1048684 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when sending 244 bytes - shutting down socket
> >>>>>> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when sending 1048684 bytes - shutting down socket
> >>>>>>
> >>>>>> on nfs-clients:
> >>>>>> [229903.273435] nfs: server 172.16.55.221 not responding, still trying
> >>>>>> [229903.523455] nfs: server 172.16.55.221 OK
> >>>>>> [229939.080276] nfs: server 172.16.55.221 OK
> >>>>>> [236527.473064] perf: interrupt took too long (6226 > 6217), lowering kernel.perf_event_max_sample_rate to 32000
> >>>>>> [248874.777322] RPC: Could not send backchannel reply error: -105
> >>>>>> [249484.823793] RPC: Could not send backchannel reply error: -105
> >>>>>> [250382.497448] RPC: Could not send backchannel reply error: -105
> >>>>>> [250671.054112] RPC: Could not send backchannel reply error: -105
> >>>>>> [251284.622707] RPC: Could not send backchannel reply error: -105
> >>>>>>
> >>>>>> Also file requests or "df -h" ended sometimes in a stale nfs status whcih will be good after a minute.
> >>>>>>
> >>>>>> I googled all messages and tried different things without success.
> >>>>>> We are now going on to upgrade cpu power on nfs server.
> >>>>>>
> >>>>>> Do you also have any hints or points i can look for?
> >>>>>>
> >>>>>> Best regards,
> >>>>>> Volker
> >>>>>
> >>>>
> >>>> --
> >>>> Chuck Lever
> >>>> chucklever@gmail.com
> >>
> >> --
> >> Chuck Lever
> >>
> >>
> >>
>
