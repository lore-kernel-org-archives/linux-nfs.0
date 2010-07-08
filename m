From: sfaibish <sfaibish@emc.com>
Subject: Re: 4.1 client - LAYOUTCOMMIT & close
Date: Thu, 08 Jul 2010 19:57:37 -0400
Message-ID: <op.vfjt6bolunckof@usensfaibisl2e.eng.emc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
	<B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>
	<1278448834.16176.5.camel@heimdal.trondhjem.org>
	<4C346D80.8010405@panasas.com>
	<1278507985.2804.30.camel@heimdal.trondhjem.org>
	<1278508696.2804.35.camel@heimdal.trondhjem.org>
	<4C348679.6010507@panasas.com>
	<1278511416.2804.52.camel@heimdal.trondhjem.org>
	<B9A709F368FAAF4DB4B33870F72A141D0106B6B0@CORPUSMX30A.corp.emc.com>
	<1278536484.12889.4.camel@heimdal.trondhjem.org>
	<BF3BB6D12298F54B89C8DCC1E4073D8001ADDDA5@CORPUSMX50A.corp.emc.com>
	<C2D311A6F086424F99E385949ECFEBCB030F2A80@CORPUSMX80B.corp.emc.com>
	<1278543175.15524.2.camel@heimdal.trondhjem.org>
	<1278544149.15524.15.camel@heimdal.trondhjem.org>
	<1278544497.15524.17.camel@heimdal.trondhje! m .org>
	<	4C35F5E3.3000604@panasas.com>
	<C2D311A6F086424F99E385949ECFEBCB030F2EBF@CORPUSMX80B.corp.emc.com>
	<op.vfjpblgeunckof@usensfaibisl2e.eng.emc.com>
	<4C3658BC.2060207@oracle.! com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"; Format="flowed"; DelSp="yes"
Cc: linux-nfs@vger.kernel.org, garth@panasas.com, welch@panasas.com,
	nfsv4@ietf.org, trond.myklebust@fys.uio.no, andros@netapp.com,
	bhalevy@panasas.com
To: "Tom Haynes" <tom.haynes@oracle.com>
Return-path: <nfsv4-bounces@ietf.org>
In-Reply-To: <4C3658BC.2060207@oracle.com>
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 08 Jul 2010 19:01:16 -0400, Tom Haynes <tom.haynes@oracle.com>  =

wrote:

> On 07/ 8/10 05:12 PM, sfaibish wrote:
>> All, After discussing this issue with Dave Noveck and as I mentioned in  =

>> the
>> call today I think that this is a serious issue and a disconnect between
>> different layout types behavior. My proposal is to have this discussion  =

>> F2F
>> in Maastricht on the white board. So I will add an agenda item to the WG
>> on this topic. I could address the behavior of the block layout but
>> it is not something we want to mimic as we all agreed at cthon to avoid  =

>> the
>> LAYOUTCOMMIT as much as possible for file layout. If we solve the
>> issue using the proposed mechanism (Trond) we will create a conflict
>> with the use of LAYOUTCOMMIT. Just as a hint the difference from block  =

>> is
>> that block uses layout for write and read as different leases and
>> when a client has layout for read the server will always send him
>> a LAYOUTRETURN when either upgrading his lease to write of send a layout
>> for write to another client. We don't want to do same for file, I
>> don't think so. My 2c.
>>
>> /Sorin
>
> When I hear the words "white board", I immediately think unorganized and  =

> likely
> to get out of hand. I don't know how much time we are up to now, but we  =

> must
> be close to running out of it.
>
> I have a counter-proposal, why doesn't someone, say Trond, put together
> some slides on this and we discuss them.
Agreed. This is what I thought about "white board" a presentation followed  =

by
a discussion on plan of action, perhaps a new 4.2 draft if there is a need.
We can continue it in the email after we decide what to do.

>
> Or, if there is a strong consensus that we do need to do this on a white
> board, why don't we ask ietf for an additional slot in the morning?
My bad using the wrong term. I don't think we need a special time slot
but we can decide on the spot in Maastricht. We should be able to find a
room available.

>
>



-- =

Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC=B2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
