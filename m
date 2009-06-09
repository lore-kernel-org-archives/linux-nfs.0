From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [round2 PATCH 0/7] nfs-utils: add support for authenticated
	callbacks
Date: Tue, 9 Jun 2009 17:43:36 -0400
Message-ID: <4d569c330906091443l1f1bb1bdta32d09bce24ffba0@mail.gmail.com>
References: <20090520151651.2986.29621.stgit@jazz.citi.umich.edu>
	 <4A296A95.3070208@RedHat.com>
	 <4d569c330906051247y7e24a7d4q3392b1481954447c@mail.gmail.com>
	 <4A2EB3BC.8040802@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:54466 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749AbZFIVnf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2009 17:43:35 -0400
Received: by qw-out-2122.google.com with SMTP id 5so211146qwd.37
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2009 14:43:36 -0700 (PDT)
In-Reply-To: <4A2EB3BC.8040802-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 9, 2009 at 3:10 PM, Steve Dickson<SteveD@redhat.com> wrote:
>
>
> Kevin Coffman wrote:
>> On Fri, Jun 5, 2009 at 2:57 PM, Steve Dickson<SteveD@redhat.com> wro=
te:
>>> Kevin Coffman wrote:
>>>> Hi Steve,
>>>>
>>>> This series adds support to gssd and svcgssd to support
>>>> authenticated callbacks.
>>>>
>>>> 1) adds the name the client used when authenticating to the
>>>> svcgssd downcall information. =A0This is used by nfsd to determine
>>>> the target name when initiating the callback.
>>>>
>>>> 2) splits out the processing of update_client_list() to accomodate
>>>> a new upcall pipe added in the next patch.
>>>>
>>>> 3) changes gssd to process all rpc_pipefs directories (this patch =
is
>>>> changed from the first round to process all directories rather tha=
n
>>>> special-casing directories)
>>>>
>>>> 4) a debugging aid to distinquish which upcall is being processed
>>>>
>>>> 6) adds support for handling the "target=3D" attribute in the new =
upcall
>>>>
>>>> 7) adds support for handling the "service=3D" attribute in the new=
 upcall
>>>>
>>>> NOTE: =A0For authenticated callbacks to work, an NFS client or an
>>>> NFS server must be running both rpcgssd _and_ rpcsvcgssd.
>>>> This will require a configuration change.
>>> Question, How are authenticated callbacks are not configured?
>>> Also do both daemons have to be running if authenticated
>>> callbacks are not configured?
>>>
>>> steved.
>>
>> Hi Steve,
>> AFAIK, there isn't a way to turn off the attempt to do the
>> authenticated callback. =A0I think that's what you mean by how are t=
hey
>> not configured?
>>
>> So for example, if the nfs client is not running svcgssd, the server
>> will attempt the callback (with authentication), and the upcall
>> request will time out and fail. =A0If the NFS server is not running
>> gssd, when it attempts to establish the callback its upcall to gssd
>> will time out and you'll get the printks warning that the daemon is
>> not running.
> hmm... I'm unable to see these failures you are talking about which i=
s
> a good thing, but It also means I'm probably not understanding someth=
ing...
>
> Question: when these request time out happen, will they cause the krb=
5
> mount to fail or access denied to users with valid krb5 tickets?
>
> steved.

Hi Steve,

To kick off the [delegation] callback, a user on the client has to do
an open after the mount.  The first open from a client should cause
the server to try to establish the callback to that client machine.

=46ailure to establish the callback shouldn't cause anything to fail,
(there just won't be delegations).  However, without gssd running on
the server, the upcall failure (timeout) will be logged as I noted.

K.C.
