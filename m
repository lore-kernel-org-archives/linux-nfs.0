From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: [NFS] "used greatest stack depth: n bytes left" messages
Date: Wed, 12 Sep 2007 14:54:08 +0200
Message-ID: <46E7E170.8000903@bull.net>
References: <46E7CD31.4080306@bull.net>
	<4d569c330709120510o3146454bo44b0a83cc01a6a99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, nfsv4 <nfsv4@linux-nfs.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c330709120510o3146454bo44b0a83cc01a6a99@mail.gmail.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Kevin Coffman a =E9crit :

>On 9/12/07, Le Rouzic <aime.le-rouzic@bull.net> wrote:
>  =

>
>>
>> Hi,
>>
>>Since 2.6.23-RC5 we can get the following kind of messages in
>>/var/log/messages:
>>
>>Sep 11 12:22:40 frec kernel: loadkeys used greatest stack depth: 4568
>>bytes left
>>Sep 11 12:22:40 frec kernel: rc.sysinit used greatest stack depth: 4448
>>bytes left
>>Sep 11 12:22:40 frec kernel: readahead used greatest stack depth: 4264
>>bytes left
>>Sep 11 13:38:36 frec kernel: mount.nfs4 used greatest stack depth: 4088
>>bytes left
>>Sep 11 17:12:08 frec kernel: mount.nfs4 used greatest stack depth: 3512
>>bytes left
>>
>>Are there only WARNINGs?
>>Does that mean we need to act on some kernel parameter ? Which one?
>>Can we conclude anything is not normal?
>>How nfsv4 can be impacted in its behavior?
>>
>>Cheers
>>    =

>>
>
>You must have changed your kernel configuration to include stack debugging?
>This message comes from kerne/exit.c and is #ifdef'd with
>CONFIG_DEBUG_STACK_USAGE.  So it seems to be more of a debug warning.
>
>  =

>
   Hi,
  CONFIG_DEBUG_STACK_USAGE was already set in my previous kernel configurat=
ion
  but those messages are new  but like you wrote more for debug warning.
  Nevertheless the question was more to know if they mean some degradation
  happening. So far, it looks not.

  Cheers

 =


-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =
