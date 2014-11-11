Return-Path: SteveD@redhat.com
Message-ID: <546262B3.7040506@RedHat.com>
Date: Tue, 11 Nov 2014 14:25:39 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Boaz Harrosh <ooo@electrozaur.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com> <54622ADF.4080807@Netapp.com> <546238D9.2030804@electrozaur.com>
In-Reply-To: <546238D9.2030804@electrozaur.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 11/11/2014 11:27 AM, Boaz Harrosh wrote:
> On 11/11/2014 05:27 PM, Anna Schumaker wrote:
> 
>>
>> I don't think so. Right now users know that if they don't use a minor
>> version then they'll be getting a v4.0 mount. I think we should keep
>> this behavior so we don't accidentally break people's configuration.
>>
> 
> This would be inconsistent and there for unexpected.
> 
> What you suggest is:
> * if user specifies no version then start with 4.1, work down to supported version
> * if user specifies major=4 only try 4.0
> * if user specifies major.minor only try major.minor
> 
> I think a more expect behavior would be:
> * if user specifies no version then start with 4.1, work down to supported version
> * if user specifies major=4 start with 4.1 til 4.0
> * if user specifies major.minor only try major.minor
I agree with Boaz... This makes more sense, IMHO... 

We put all this work to make 4.1 the better minor version 
and then we are not going to default to it when -o v4 is used? 

At the end of the day, which minor version is being
used should be seamless to the user. So when they
specify -o v4, we'll  decide which minor version 
should be used, as long as there is a way to 
override it (which there will be).

steved.
 
> 
> The preferred (implicit) minor is 1 in all cases
> 
> The question is did users of major=4 meant 4.0 and were lazy to type ".0"
> or did they mean "don't try 3 or 2"
> 
> Current system compatibility is already changing by moving all
> case 1 above from 4.0 to 4.1 by the next yum update. I think it would
> be reasonable to also change case 2. And have a consistent semantics.
> 
>> Anna
>>
> 
> Thanks
> Boaz
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
